import { ArtistsDto } from './artists/dto/artist.dto';
import { MusicDto } from './music/dto/music.dto';
import { PlaylistDto } from './playlists/dto/playlist.dto';
import { UsersDto } from './users/dto/user.dto';

export class SearchResultDto {
  titles: MusicDto[];
  artists: ArtistsDto[];
  playlists: PlaylistDto[];
  users: UsersDto[];
}
