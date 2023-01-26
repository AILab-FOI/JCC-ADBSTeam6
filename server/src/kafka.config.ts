import { KafkaOptions, Transport } from '@nestjs/microservices';

export const KAFKA_CONFIG: KafkaOptions = {
  transport: Transport.KAFKA,
  options: {
    client: {
      clientId: process.env.KAFKA_CLIENT_ID,
      brokers: process.env.KAFKA_URIS.split(','),
    },
    consumer: {
      groupId: 'nestjs-group-client',
    },
    subscribe: {
      fromBeginning: true,
    },
  },
};
