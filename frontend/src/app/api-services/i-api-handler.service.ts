import { ArtistsDto } from 'src/types/api-dto/ArtistsDto';
import { CommentsDto } from 'src/types/api-dto/CommentsDto';
import { FullMusicDto } from 'src/types/api-dto/FullMusicDto';
import { GenresDto } from 'src/types/api-dto/GenresDto';
import { MusicCreateDto } from 'src/types/api-dto/MusicCreateDto';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { SearchResultDto } from 'src/types/api-dto/SearchResultDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';

export interface IApiHandlerService {
  fetchAllPlaylist(limit: number, offset: number): Promise<PlaylistsDto[]>;

  fetchAllGenres(limit: number, offset: number): Promise<GenresDto[]>;

  fetchAllArtists(limit: number, offset: number): Promise<ArtistsDto[]>;

  fetchHitMusic(limit: number, offser: number): Promise<MusicDto[]>;

  submitMusic(data: MusicCreateDto, file: File, token: string): Promise<number>;

  fetchUserById(userId: number): Promise<UsersDto | null>;

  fetchPlaylistByOwnerId(ownerId: number): Promise<PlaylistsDto[]>;

  fetchSubscriptionsByUserId(userId: number): Promise<UsersDto[]>;

  fetchSubscribeState(subscribeTo: number, token: string): Promise<boolean>;

  subscribe(subscribeTo: number, token: string): Promise<void>;

  increaseViewsCounter(musicId: number): Promise<void>;

  unsubscribe(subscribeTo: number, token: string): Promise<void>;

  fetchCommentsByWritterId(
    writterId: number,
    limit: number,
    offset: number
  ): Promise<CommentsDto[]>;

  fetchMusicArtistsById(
    musicId: number,
    limit: number,
    offset: number
  ): Promise<ArtistsDto[]>;

  fetchPlaylistById(playlistId: number): Promise<PlaylistsDto | null>;

  fetchMusicPlaylistById(
    playlistId: number,
    limit: number,
    offset: number
  ): Promise<MusicDto[]>;

  fetchMusicById(musicId: number): Promise<MusicDto | null>;

  fetchMusicByGenresId(
    genreId: number,
    limit: number,
    offset: number
  ): Promise<MusicDto[]>;

  fetchLikeState(musicId: number, token: string): Promise<boolean>;

  like(musicId: number, token: string): Promise<void>;

  unlike(musicId: number, token: string): Promise<void>;

  deleteComment(commentId: number, token: string): Promise<void>;

  publishComment(
    content: string,
    musicId: number,
    token: string
  ): Promise<CommentsDto | null>;

  fetchCommentsByMusicId(
    musicId: number,
    limit: number,
    offset: number
  ): Promise<CommentsDto[]>;

  addMusicToPlaylist(
    playlistId: number,
    musicId: number,
    token: string
  ): Promise<void>;

  removeMusicFromPlaylist(
    playlistID: number,
    musicId: number,
    token: string
  ): Promise<void>;

  fetchUserPlaylistsWithMusics(
    userId: number,
    limit: number,
    offset: number
  ): Promise<(PlaylistsDto & { musics: MusicDto[] })[]>;

  fetchMusicBufferBlock(
    musicId: number,
    blocknumber: number,
    Nblocks: number
  ): Promise<ArrayBuffer>;

  fetchArtistById(artistId: number): Promise<ArtistsDto | null>;

  searchByText(
    text: string,
    limit: number,
    offset: number
  ): Promise<SearchResultDto>;

  deleteMusic(musicId: number, token: string): Promise<MusicDto | null>;

  login({
    email,
    password,
  }: {
    email: string;
    password: string;
  }): Promise<{ token: string; user: UsersDto }>;

  fetchMusicOfArtist(
    artistId: number,
    limit: number,
    offset: number
  ): Promise<MusicDto[]>;

  register({
    lastName,
    firstName,
    email,
    password,
    username,
  }: {
    lastName: string;
    firstName: string;
    email: string;
    password: string;
    username: string;
  }): Promise<UsersDto>;

  fetchMusicLikeNumber(musicId: number): Promise<number>;

  fetchMusicViewNumber(musicId: number): Promise<number>;

  createPlaylist(
    { name, description }: { name: string; description: string },
    token: string
  ): Promise<PlaylistsDto>;
}
