import { Module } from '@nestjs/common';
import { CommentsService } from './comments.service';
import { CommentsController } from './comments.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Comments } from './entities/comment.entity';
import { Users } from '@/users/entities/user.entity';
import { Music } from '@/music/entities/music.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Comments, Users, Music])],
  controllers: [CommentsController],
  providers: [CommentsService],
})
export class CommentsModule {}
