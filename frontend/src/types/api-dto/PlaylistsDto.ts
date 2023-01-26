import { UsersDto } from './UsersDto';

export interface PlaylistsDto {
  playlistID: number;
  name: String;
  description: String;
  user: UsersDto;
}
