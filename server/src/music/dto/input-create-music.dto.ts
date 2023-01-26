export class InputCreateMusicDto {
  title: string;
  description: string | null;
  turnoffcomments: boolean | null;
  genres: string; // '[1,2,3]'
  artists: string; // '[1,2,3]'
}
