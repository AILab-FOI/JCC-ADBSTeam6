import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  Req,
  ParseIntPipe,
} from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { UpdateSubscriptionDto } from './dto/update-subscription.dto';
import { UsersDto } from '@/users/dto/user.dto';
import { extractLimitOffset } from '@/helpers';
import { JwtAuthGuard } from '@/auth/jwt-auth.guard';

@Controller('api/subscriptions')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Post()
  create(@Body() createSubscriptionDto: CreateSubscriptionDto) {
    return this.subscriptionsService.create(createSubscriptionDto);
  }

  @Get()
  findAll() {
    return this.subscriptionsService.findAll();
  }

  @UseGuards(JwtAuthGuard)
  @Post('/subscribe/:id')
  async subscribeTo(
    @Param('id') subscribeToId: string,
    @Req() req: { user: UsersDto },
  ): Promise<void> {
    return this.subscriptionsService.subscribe(req.user.userID, +subscribeToId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('/unsubscribe/:id')
  async unsubscribeTo(
    @Param('id') subscribeToId: string,
    @Req() req: { user: UsersDto },
  ): Promise<void> {
    return this.subscriptionsService.unsubscribe(
      req.user.userID,
      +subscribeToId,
    );
  }

  /**
   * /subscriptions/user/:id
   */
  @UseGuards(JwtAuthGuard)
  @Get('/to/:id')
  async userIsSubscribedTo(
    @Param('id', ParseIntPipe) subscribeToId: number,
    @Req() req: { user: UsersDto },
  ): Promise<boolean> {
    return this.subscriptionsService.isSubscribeTo(
      req.user.userID,
      subscribeToId,
    );
  }

  /**
   * /subscriptions/user/:id?limit=<int?>&offset=<int?>
   */
  @Get('/user/:id')
  async findAllByUserId(
    @Param('id') userId: string,
    @Query() query,
  ): Promise<UsersDto[]> {
    const { limit, offset } = extractLimitOffset(query);

    return this.subscriptionsService.findByUserId(+userId, limit, offset);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.subscriptionsService.findOne(+id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateSubscriptionDto: UpdateSubscriptionDto,
  ) {
    return this.subscriptionsService.update(+id, updateSubscriptionDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.subscriptionsService.remove(+id);
  }
}
