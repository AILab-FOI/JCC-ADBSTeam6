import { setSkipAndTake } from '@/helpers';
import { toUserDto } from '@/mapper/users.mapper';
import { UsersDto } from '@/users/dto/user.dto';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { UpdateSubscriptionDto } from './dto/update-subscription.dto';
import { Subscriptions } from './entities/subscription.entity';

@Injectable()
export class SubscriptionsService {
  constructor(
    @InjectRepository(Subscriptions)
    private subscriptionRepository: Repository<Subscriptions>,
  ) {}

  create(createSubscriptionDto: CreateSubscriptionDto) {
    return 'This action adds a new subscription';
  }

  findAll() {
    return `This action returns all subscriptions`;
  }

  findOne(id: number) {
    return `This action returns a #${id} subscription`;
  }

  async subscribe(userId: number, subscribeToId: number): Promise<void> {
    const subscriptions = this.subscriptionRepository.create({
      userid: userId,
      subscribetoid: subscribeToId,
    });

    await this.subscriptionRepository.save(subscriptions);
  }

  async unsubscribe(userId: number, subscribeToId: number): Promise<void> {
    await this.subscriptionRepository.delete({
      userid: userId,
      subscribetoid: subscribeToId,
    });
  }

  async isSubscribeTo(userId: number, subscribeToId: number): Promise<boolean> {
    const subscription = await this.subscriptionRepository.findOne({
      where: {
        userid: userId,
        subscribetoid: subscribeToId,
      },
    });

    return !!subscription;
  }

  async findByUserId(
    userId: number,
    limit: number,
    offset: number,
  ): Promise<UsersDto[]> {
    const subscriptionList = await this.subscriptionRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        userid: userId,
      },
      relations: {
        subscribeto: {
          role: true,
        },
      },
    });

    return subscriptionList.map((sub) => sub.subscribeto).map(toUserDto);
  }

  update(id: number, updateSubscriptionDto: UpdateSubscriptionDto) {
    return `This action updates a #${id} subscription`;
  }

  remove(id: number) {
    return `This action removes a #${id} subscription`;
  }
}
