import { Pipe, PipeTransform } from '@angular/core';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';

@Pipe({
  name: 'noAutoPlaylist',
  pure: false,
})
export class NoAutoPlaylistPipe implements PipeTransform {
  transform(items: PlaylistsDto[], ...args: unknown[]): PlaylistsDto[] {
    const forbidden = ['my music', 'liked music'];

    return items.filter((a) => !forbidden.includes(a.name.toLowerCase()));
  }
}
