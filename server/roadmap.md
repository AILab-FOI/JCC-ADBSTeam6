# Backend roadmap

## API endpoints to implement 

From frontend `IApiHandler` interface:

```ts
fetchAllPlaylist(limit: number, offset: number): Promise<PlaylistsDto[]>; ✅

fetchAllGenres(limit: number, offset: number): Promise<GenresDto[]>; ✅

fetchAllArtists(limit: number, offset: number): Promise<ArtistsDto[]>; ✅

fetchHitMusic(): Promise<MusicDto[]>; ✅

submitMusic(data: MusicCreateDto, file: File, token: string): Promise<number>; ✅

fetchUserById(userId: number): Promise<UsersDto | null>; ✅

fetchPlaylistByOwnerId(ownerId: number): Promise<PlaylistsDto[]>; ✅

fetchSubscriptionsByUserId(userId: number): Promise<UsersDto[]>; ✅

fetchSubscribeState(subscribeTo: number, token: string): Promise<boolean>; ✅

subscribe(subscribeTo: number, token: string): Promise<void>; ✅

unsubscribe(subscribeTo: number, token: string): Promise<void>; ✅

fetchCommentsByWritterId(writterId: number): Promise<CommentsDto[]>; ✅

fetchMusicArtistsById(musicId: number): Promise<ArtistsDto[]>; ✅

fetchPlaylistById(playlistId: number): Promise<PlaylistsDto | null>; ✅

fetchMusicPlaylistById(playlistId: number): Promise<MusicDto[]>; ✅

fetchMusicById(musicId: number): Promise<MusicDto | null>; ✅

fetchMusicByGenresId(genreId: number): Promise<MusicDto[]>; ✅

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
): Promise<CommentsDto[]>; ✅

addMusicToPlaylist(
    playlistId: number,
    musicId: number,
    token: string
): Promise<void>; ✅

removeMusicFromPlaylist(
    playlistID: number,
    musicId: number,
    token: string
): Promise<void>; ✅

fetchMusicBufferBlock(
    musicId: number,
    blocknumber: number,
    Nblocks: number
): Promise<ArrayBuffer>; ✅

fetchUserPlaylists<B extends boolean>(
    userId: number,
    withMusic: B
): Promise<
    B extends true ? (PlaylistsDto & { musics: MusicDto[] })[] : PlaylistsDto[]
>;

fetchArtistById(artistId: number): Promise<ArtistsDto | null>; ✅

searchByText(text: string, limit: number): Promise<SearchResultDto>; ✅

login({
    email,
    password,
}: {
    email: string;
    password: string;
}): Promise<{ token: string; user: UsersDto }>; ✅

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
}): Promise<UsersDto>; ✅
```