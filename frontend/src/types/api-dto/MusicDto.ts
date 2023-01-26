import { ArtistsDto } from './ArtistsDto';
import { GenresDto } from './GenresDto';

export interface MusicDto {
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
