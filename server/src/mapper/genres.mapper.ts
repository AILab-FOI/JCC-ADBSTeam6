import { GenresDto } from '@/genres/dto/genres.dto';
import { Genres } from '@/genres/entities/genre.entity';

export function toGenresDto(genre: Genres): GenresDto {
  return {
    tagID: genre.genreid,
    name: genre.name,
  };
}
