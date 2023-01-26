import { Module } from '@nestjs/common';
import { ArtistsService } from './artists.service';
import { ArtistsController } from './artists.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Artists } from './entities/artist.entity';
import { Music } from '@/music/entities/music.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Artists, Music])],
  controllers: [ArtistsController],
  providers: [ArtistsService],
  exports: [ArtistsService],
})
export class ArtistsModule {}
