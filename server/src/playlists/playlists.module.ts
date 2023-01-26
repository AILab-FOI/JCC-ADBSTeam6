import { Module } from '@nestjs/common';
import { PlaylistsService } from './playlists.service';
import { PlaylistsController } from './playlists.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Playlists } from './entities/playlist.entity';
import { Users } from '@/users/entities/user.entity';
import { Playlistmusic } from '@/playlist-musics/entities/playlist-music.entity';
import { MusicModule } from '@/music/music.module';
import { PlaylistMusicsModule } from '@/playlist-musics/playlist-musics.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Playlists, Users, Playlistmusic]),
    MusicModule,
    PlaylistMusicsModule,
  ],
  controllers: [PlaylistsController],
  providers: [PlaylistsService],
})
export class PlaylistsModule {}
