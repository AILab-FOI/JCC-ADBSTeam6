export class CreateMusicDto {
  title: string;
  description: string | null;
  turnoffcomments: boolean | null;
  genres: number[];
  artists: number[];
}
