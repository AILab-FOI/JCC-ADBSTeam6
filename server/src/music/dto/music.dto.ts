import { ArtistsDto } from '@/artists/dto/artist.dto';
import { GenresDto } from '@/genres/dto/genres.dto';

export class MusicDto {
  musicID: number;
  title: string;
  description: string;
  publicationDate: string;
  turnOffComments: boolean;
  duration: string;
  Users_userID: number;
  genres: GenresDto[];
  artists: ArtistsDto[];
}
