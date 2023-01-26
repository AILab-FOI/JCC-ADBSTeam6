import { Module } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { SubscriptionsController } from './subscriptions.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Subscriptions } from './entities/subscription.entity';
import { Users } from '@/users/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Subscriptions, Users])],
  controllers: [SubscriptionsController],
  providers: [SubscriptionsService],
})
export class SubscriptionsModule {}
