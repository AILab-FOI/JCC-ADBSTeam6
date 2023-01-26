import { PlaylistDto } from '@/playlists/dto/playlist.dto';
import { Playlists } from '@/playlists/entities/playlist.entity';
import { toUserDto } from './users.mapper';

export function toPlaylistDto(playlist: Playlists): PlaylistDto {
  return {
    playlistID: playlist.playlistid,
    name: playlist.name,
    description: playlist.description,
    user: toUserDto(playlist.user),
  };
}
