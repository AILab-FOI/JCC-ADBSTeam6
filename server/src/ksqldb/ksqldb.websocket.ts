import { KAFKA_CONFIG } from '@/kafka.config';
import { Inject, Logger, ParseIntPipe } from '@nestjs/common';
import {
  Client,
  ClientKafka,
  EventPattern,
  MessagePattern,
  Payload,
} from '@nestjs/microservices';
import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Socket } from 'dgram';
import { Consumer, Kafka } from 'kafkajs';
import { MusicStatsPayloadDto } from './dto/MusicStatsPayload.dto';
import { KsqldbService } from './ksqldb.service';

// https://stackoverflow.com/questions/67230791/websocket-with-nestjs-and-angular
@WebSocketGateway(8082, {
  transports: ['websocket'],
  cors: {
    allowedHeaders: [
      'content-type',
      'authorization',
      'Access-Control-Allow-Headers',
      'accept',
      'content-length',
    ],
    origin: 'http://localhost:4200',
    credentials: true,
  },
})
export class KsqldbWebsocket {
  @WebSocketServer() server: any;

  private logger = new Logger('KSQLDB websocket');

  private kafka = new Kafka({
    clientId: process.env.KAFKA_CLIENT_ID,
    brokers: process.env.KAFKA_URIS.split(','),
  });

  private consumer = this.kafka.consumer({
    groupId: 'nestjs-group-client',
    retry: {
      // Try to reconnect after 10seg
      initialRetryTime: 10 * 1000,
      retries: 10,
    },
    heartbeatInterval: 25000,
  });

  private topicHandlerMap: {
    [key: string]: (payload: any) => void | PromiseLike<void>;
  } = {};

  constructor(private ksqldbService: KsqldbService) {}

  private consume(
    topicName: string,
    handler: (payload: any) => void | PromiseLike<void>,
  ): void {
    this.topicHandlerMap[topicName] = handler;
  }

  async onModuleInit() {
    await this.consumer.connect();

    this.consume('MusicData', (data) =>
      this.handleMusicStatsUpdate({
        musicId: data.MUSICID,
        views: data.VIEWS,
        likes: data.LIKES,
      }),
    );

    await this.consumer.subscribe({
      topics: Object.keys(this.topicHandlerMap),
    });

    await this.consumer
      .run({
        eachMessage: async ({ topic, message }) => {
          if (Object.keys(this.topicHandlerMap).includes(topic)) {
            const data = JSON.parse(message.value.toString('utf-8'));
            this.topicHandlerMap[topic](data);
          } else {
            this.logger.warn(`Encounter unknown topic: ${topic}.`);
          }
        },
      })
      .catch((err) => this.logger.error(err));

    // topicToSubscribeTo.forEach((topicName) => {
    //   console.log(`Subscribe to ${topicName}`);

    //   this.kafkaClient.subscribeToResponseOf(topicName);
    // });

    this.logger.log('WS connected on port 8082!');
    // await this.kafkaClient.connect();
    // this.kafkaClient.emit('test-data', 'Hi!');
  }

  @MessagePattern('music-data')
  @EventPattern('music-data')
  handleMusicStatsUpdate(@Payload() payload: MusicStatsPayloadDto): void {
    // this.logger.log('RECEIVE DATA');
    // console.log({ payload });

    this.server.emit('musicStats', payload);
  }

  @SubscribeMessage('askMusicStats')
  async handleAskMusicStatis(
    @ConnectedSocket() client: Socket,
    @MessageBody('musicId', ParseIntPipe) musicId: number,
  ): Promise<void> {
    this.logger.log('Received on askMusicStats data ' + musicId);
    const musicStats: MusicStatsPayloadDto =
      await this.ksqldbService.findOneMusicStat(musicId);
    client.emit('musicStats', musicStats);
  }
}
