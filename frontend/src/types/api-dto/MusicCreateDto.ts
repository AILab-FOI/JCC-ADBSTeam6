export interface MusicCreateDto {
  title: string;
  description: string;
  turnOffComments: boolean;
  artistIds: number[];
  genreIds: number[];
}
