import { ArtistsDto } from '@/artists/dto/artist.dto';
import { Artists } from '@/artists/entities/artist.entity';

export function toArtistsDto(artists: Artists): ArtistsDto {
  return {
    artistID: artists.artistid,
    name: artists.name,
  };
}
