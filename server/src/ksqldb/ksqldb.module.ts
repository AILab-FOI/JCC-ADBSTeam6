import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { KsqldbService } from './ksqldb.service';
import { KsqldbWebsocket } from './ksqldb.websocket';

@Module({
  imports: [
    HttpModule,
    ClientsModule.register([
      {
        name: 'KAFKA_CLIENT',
        transport: Transport.KAFKA,
        options: {
          client: {
            clientId: process.env.KAFKA_CLIENT_ID,
            brokers: process.env.KAFKA_URIS.split(','),
          },
        },
      },
    ]),
  ],
  providers: [KsqldbWebsocket, KsqldbService],
  exports: [KsqldbService],
})
export class KsqldbModule {}
