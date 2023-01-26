import { Module } from '@nestjs/common';
import { UsersService } from '@/users/users.service';
import { UsersController } from '@/users/users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Users } from '@/users/entities/user.entity';
import { Comments } from '@/comments/entities/comment.entity';
import { Playlists } from '@/playlists/entities/playlist.entity';
import { Subscriptions } from '@/subscriptions/entities/subscription.entity';
import { Roles } from '@/roles/entities/role.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Users,
      Comments,
      Playlists,
      Subscriptions,
      Roles,
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
