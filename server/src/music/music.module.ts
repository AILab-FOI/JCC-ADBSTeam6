import { Module } from '@nestjs/common';
import { MusicService } from './music.service';
import { MusicController } from './music.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Music } from './entities/music.entity';
import { Users } from '@/users/entities/user.entity';
import { Comments } from '@/comments/entities/comment.entity';
import { Artists } from '@/artists/entities/artist.entity';
import { Genres } from '@/genres/entities/genre.entity';
import { Playlistmusic } from '@/playlist-musics/entities/playlist-music.entity';
import { ArtistsModule } from '@/artists/artists.module';
import { GenresModule } from '@/genres/genres.module';
import { UsersModule } from '@/users/users.module';
import { PlaylistMusicsModule } from '@/playlist-musics/playlist-musics.module';
import { KsqldbService } from '@/ksqldb/ksqldb.service';
import { HttpModule } from '@nestjs/axios';
import { KsqldbModule } from '@/ksqldb/ksqldb.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Music,
      Users,
      Comments,
      Artists,
      Genres,
      Playlistmusic,
    ]),
    ArtistsModule,
    GenresModule,
    UsersModule,
    PlaylistMusicsModule,
    KsqldbModule,
  ],
  controllers: [MusicController],
  providers: [MusicService],
  exports: [MusicService],
})
export class MusicModule {}
