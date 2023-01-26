import { Module } from '@nestjs/common';
import { GenresService } from './genres.service';
import { GenresController } from './genres.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Genres } from './entities/genre.entity';
import { Music } from '@/music/entities/music.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Genres, Music])],
  controllers: [GenresController],
  providers: [GenresService],
  exports: [GenresService],
})
export class GenresModule {}
