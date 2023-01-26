import { SearchResultTypeEnum } from '../SearchResultType.enum';
import { ArtistsDto } from './ArtistsDto';
import { MusicDto } from './MusicDto';
import { PlaylistsDto } from './PlaylistsDto';
import { UsersDto } from './UsersDto';

export type SearchResultDto = {
  titles: MusicDto[];
  artists: ArtistsDto[];
  playlists: PlaylistsDto[];
  users: UsersDto[];
};
