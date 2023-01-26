import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { Transport } from '@nestjs/microservices';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { KAFKA_CONFIG } from './kafka.config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors({
    allowedHeaders: [
      'content-type',
      'authorization',
      'Access-Control-Allow-Headers',
      'accept',
      'content-length',
    ],
    origin: 'http://localhost:4200',
    credentials: true,
  });

  // app.connectMicroservice(KAFKA_CONFIG);

  // await app.startAllMicroservices();

  const config = new DocumentBuilder()
    .setTitle('webadmin API')
    .setDescription('The webadmin API description')
    .setVersion('1.0')
    .addTag('webadmin')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  await app.listen(3000).then(() => Logger.log('App listen on port 3000. 🚀'));
}
bootstrap();
