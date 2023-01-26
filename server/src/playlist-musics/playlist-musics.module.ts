import { Module } from '@nestjs/common';
import { PlaylistMusicsService } from './playlist-musics.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Playlistmusic } from './entities/playlist-music.entity';
import { Playlists } from '@/playlists/entities/playlist.entity';
import { Music } from '@/music/entities/music.entity';
import { MusicModule } from '@/music/music.module';
import { PlaylistsModule } from '@/playlists/playlists.module';

@Module({
  imports: [TypeOrmModule.forFeature([Playlistmusic, Playlists, Music])],
  providers: [PlaylistMusicsService],
  exports: [PlaylistMusicsService],
})
export class PlaylistMusicsModule {}
