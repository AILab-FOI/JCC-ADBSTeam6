import { ArtistsDto } from './ArtistsDto';
import { CommentsDto } from './CommentsDto';
import { GenresDto } from './GenresDto';
import { MusicDto } from './MusicDto';

export type FullMusicDto = MusicDto & {
  artists: ArtistsDto[];
  genres: GenresDto[];
};
