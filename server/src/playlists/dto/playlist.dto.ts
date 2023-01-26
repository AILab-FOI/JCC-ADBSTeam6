import { UsersDto } from '@/users/dto/user.dto';

export class PlaylistDto {
  playlistID: number;
  name: string;
  description: string;
  user: UsersDto;
}
