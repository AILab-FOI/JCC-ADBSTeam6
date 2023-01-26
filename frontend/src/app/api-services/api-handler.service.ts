import { IApiHandlerService } from './i-api-handler.service';
import { ArtistsDto } from 'src/types/api-dto/ArtistsDto';
import { CommentsDto } from 'src/types/api-dto/CommentsDto';
import { GenresDto } from 'src/types/api-dto/GenresDto';
import { MusicCreateDto } from 'src/types/api-dto/MusicCreateDto';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { SearchResultDto } from 'src/types/api-dto/SearchResultDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class ApiHandlerService implements IApiHandlerService {
  readonly BASE_URL = 'http://localhost:3000/api/';

  readonly BASIC_HEADER = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  };

  private join(...paths: string[]): string {
    let s = '';
    if (paths.length === 0) return s;
    if (paths.length === 1) return paths[0];

    let newPaths: string[] = [];
    if (paths[0].at(-1) === '/')
      newPaths.push(paths[0].substring(0, paths[0].length - 1));
    for (let i = 1; i < paths.length - 1; i++) {
      let curr = paths[i];
      if (curr[0] === '/') curr = curr.substring(1);
      if (curr.at(-1) === '/') curr = curr.substring(0, paths[0].length - 1);

      newPaths.push(curr);
    }

    const last = paths.at(-1);
    if (last && last[0] === '/')
      newPaths.push(last.substring(1, paths[0].length));
    else if (last) newPaths.push(last);

    return newPaths.join('/');
  }

  private async GET<T>(
    URL: string,
    query: { [key: string]: string | number } = {},
    headers: any = this.BASIC_HEADER,
    expectArrayBuffer: boolean = false,
    baseURL: string = this.BASE_URL
  ): Promise<T> {
    let queryString = '';
    if (Object.keys(query).length > 0) {
      const queryItems = Object.keys(query).map(
        (key) => `${key}=${query[key]}`
      );
      queryString = '?' + queryItems.join('&');
    }

    return new Promise(async (resolve, reject) => {
      const completeUrl = this.join(baseURL, URL) + queryString;
      fetch(completeUrl, { method: 'GET', headers })
        .then(async (res: Response) => {
          if (!res.ok) {
            reject(await res.json());
          } else {
            if (expectArrayBuffer) {
              res
                .arrayBuffer()
                .then((data) => resolve(data as T))
                .catch((err) => reject(err));
            } else {
              try {
                const json = await res.json();
                resolve(json);
              } catch (error) {
                if (error instanceof SyntaxError) resolve(null as any);
                else reject({ message: 'Unexpected error: ' + error });
              }
            }
          }
        })
        .catch((err) => {
          console.error(err);
          reject({ message: 'Client error' });
        });
    });
  }

  private async DELETE<T>(
    URL: string,
    headers: any = this.BASIC_HEADER,
    baseURL: string = this.BASE_URL
  ): Promise<T> {
    return new Promise(async (resolve, reject) => {
      const completeUrl = this.join(baseURL, URL);
      fetch(completeUrl, {
        method: 'DELETE',
        headers,
      })
        .then(async (res: Response) => {
          let json = null;
          try {
            json = await res.json();
          } catch (error) {
            if (error instanceof SyntaxError) {
            } else reject({ message: 'Unexpected error: ' + error });
          }

          if (!res.ok) {
            reject(json);
          } else resolve(json);
        })
        .catch((err) => {
          console.error(err);
          reject({ message: 'Client error' });
        });
    });
  }

  private async POST<T>(
    URL: string,
    data: unknown,
    headers: any = this.BASIC_HEADER,
    baseURL: string = this.BASE_URL
  ): Promise<T> {
    return new Promise(async (resolve, reject) => {
      const completeUrl = this.join(baseURL, URL);
      fetch(completeUrl, {
        method: 'POST',
        headers,
        body: data instanceof FormData ? data : JSON.stringify(data),
      })
        .then(async (res: Response) => {
          let json = null;
          try {
            json = await res.json();
          } catch (error) {
            if (error instanceof SyntaxError) {
            } else reject({ message: 'Unexpected error: ' + error });
          }

          if (!res.ok) {
            reject(json);
          } else resolve(json);
        })
        .catch((err) => {
          console.error(err);
          reject({ message: 'Client error' });
        });
    });
  }

  private httpAuthHeaderPart(
    token: string
    // additionnalHeaders: string[] = []
  ): {
    Authorization: string;
    // ['Access-Control-Allow-Headers']: string;
  } {
    return {
      Authorization: 'Bearer ' + token,
      // 'Access-Control-Allow-Headers':
      //   'Content-Type' +
      //   (additionnalHeaders.length > 0
      //     ? ', ' + additionnalHeaders.join(', ')
      //     : ''),
    };
  }

  async fetchAllPlaylist(
    limit: number,
    offset: number
  ): Promise<PlaylistsDto[]> {
    let playlists: PlaylistsDto[] = [];
    try {
      playlists = await this.GET<PlaylistsDto[]>('/playlists/', {
        limit,
        offset,
      });
    } catch (error: any) {
      throw new Error(error.message);
    }

    return playlists;
  }

  async fetchAllGenres(limit: number, offset: number): Promise<GenresDto[]> {
    let genres: GenresDto[] = [];
    try {
      genres = await this.GET<GenresDto[]>('/genres/', {
        limit,
        offset,
      });
    } catch (error: any) {
      throw new Error(error.message);
    }

    return genres;
  }

  async deleteMusic(musicId: number, token: string): Promise<MusicDto | null> {
    let music = null;
    try {
      music = this.DELETE<MusicDto | null>(`/music/` + musicId, {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      });
    } catch (error: any) {
      throw new Error(error.message);
    }

    return music;
  }

  async fetchAllArtists(limit: number, offset: number): Promise<ArtistsDto[]> {
    let artists: ArtistsDto[] = [];
    try {
      artists = await this.GET<ArtistsDto[]>('/artists/', {
        limit,
        offset,
      });
    } catch (error: any) {
      throw new Error(error.message);
    }

    return artists;
  }

  async fetchHitMusic(limit: number, offset: number): Promise<MusicDto[]> {
    let musics: MusicDto[] = [];
    try {
      musics = await this.GET<MusicDto[]>('/music/hits/', { limit, offset });
    } catch (error: any) {
      throw new Error(error.message);
    }

    return musics;
  }

  async submitMusic(
    data: MusicCreateDto,
    file: File,
    token: string
  ): Promise<number> {
    let musicId: number = -1;

    let formdata = new FormData();
    formdata.append('title', data.title);
    formdata.append('description', data.description);
    formdata.append('turnoffcomments', data.turnOffComments ? 'true' : 'false');
    formdata.append('artists', JSON.stringify(data.artistIds));
    formdata.append('genres', JSON.stringify(data.genreIds));

    formdata.append('file', file);

    try {
      musicId = await this.POST<number>('/music/', formdata, {
        Accept: 'application/json,multipart/form-data',
        ...this.httpAuthHeaderPart(token),
      });
    } catch (error: any) {
      throw new Error(error.message);
    }

    return musicId;
  }

  fetchUserById(userId: number): Promise<UsersDto | null> {
    return this.GET<UsersDto | null>(`/users/${userId}`);
  }

  fetchPlaylistByOwnerId(ownerId: number): Promise<PlaylistsDto[]> {
    return this.GET<PlaylistsDto[]>(`/playlists/user/${ownerId}`);
  }

  fetchSubscriptionsByUserId(userId: number): Promise<UsersDto[]> {
    return this.GET<UsersDto[]>(`/subscriptions/user/${userId}`);
  }

  fetchSubscribeState(subscribeTo: number, token: string): Promise<boolean> {
    return this.GET<boolean>(
      `/subscriptions/to/${subscribeTo}`,
      {},
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }

  /**
   * source: https://docs.ksqldb.io/en/latest/developer-guide/api/
   */
  async fetchMusicLikeNumber(musicId: number): Promise<number> {
    const res = await this.POST<any>(
      'query',
      {
        ksql: 'SELECT LIKES FROM MUSIC WHERE MUSICID=' + musicId + ';',
        streamProperties: {},
      },
      {
        Accept: 'application/vnd.ksql.v1+json',
      },
      'http://localhost:8088'
    );

    return res[1]?.row?.columns[0] || 0;
  }

  async fetchMusicViewNumber(musicId: number): Promise<number> {
    const res = await this.POST<any>(
      'query',
      {
        ksql: 'SELECT VIEWS FROM MUSIC WHERE MUSICID=' + musicId + ';',
        streamProperties: {},
      },
      {
        Accept: 'application/vnd.ksql.v1+json',
      },
      'http://localhost:8088'
    );

    return res[1]?.row?.columns[0] || 0;
  }

  subscribe(subscribeTo: number, token: string): Promise<void> {
    return this.POST<void>(
      `subscriptions/subscribe/${subscribeTo}`,
      {},
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }

  unsubscribe(subscribeTo: number, token: string): Promise<void> {
    return this.POST<void>(
      `subscriptions/unsubscribe/${subscribeTo}`,
      {},
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }

  fetchCommentsByWritterId(
    writterId: number,
    limit: number = -1,
    offset: number = 0
  ): Promise<CommentsDto[]> {
    return this.GET<CommentsDto[]>(`comments/user/${writterId}`, {
      limit,
      offset,
    });
  }

  fetchMusicArtistsById(
    musicId: number,
    limit: number = -1,
    offset: number = 0
  ): Promise<ArtistsDto[]> {
    return this.GET<ArtistsDto[]>(`artists/music/${musicId}`, {
      limit,
      offset,
    });
  }

  fetchPlaylistById(playlistId: number): Promise<PlaylistsDto | null> {
    return this.GET<PlaylistsDto | null>(`playlists/${playlistId}`);
  }

  fetchMusicOfArtist(
    artistId: number,
    limit: number,
    offset: number
  ): Promise<MusicDto[]> {
    return this.GET<MusicDto[]>(`/music/artist/` + artistId, { limit, offset });
  }

  fetchMusicPlaylistById(
    playlistId: number,
    limit: number = -1,
    offset: number = 0
  ): Promise<MusicDto[]> {
    return this.GET<MusicDto[]>(`music/playlist/${playlistId}`, {
      limit,
      offset,
    });
  }

  fetchMusicById(musicId: number): Promise<MusicDto | null> {
    return this.GET<MusicDto | null>(`music/${musicId}`);
  }

  fetchMusicByGenresId(
    genreId: number,
    limit: number = -1,
    offset: number = 0
  ): Promise<MusicDto[]> {
    return this.GET<MusicDto[]>(`music/genres/${genreId}`, { limit, offset });
  }

  fetchLikeState(musicId: number, token: string): Promise<boolean> {
    return this.GET<boolean>(
      `/music/${musicId}/is-liked`,
      {},
      { ...this.BASIC_HEADER, ...this.httpAuthHeaderPart(token) }
    );
  }

  like(musicId: number, token: string): Promise<void> {
    return this.POST<void>(
      `/music/${musicId}/like`,
      {},
      { ...this.BASIC_HEADER, ...this.httpAuthHeaderPart(token) }
    );
  }

  increaseViewsCounter(musicId: number): Promise<void> {
    return this.POST<void>(`/music/play/${musicId}`, {});
  }

  unlike(musicId: number, token: string): Promise<void> {
    return this.POST<void>(
      `/music/${musicId}/unlike`,
      {},
      { ...this.BASIC_HEADER, ...this.httpAuthHeaderPart(token) }
    );
  }

  deleteComment(commentId: number, token: string): Promise<void> {
    return this.DELETE<void>(`/comments/` + commentId, {
      ...this.BASIC_HEADER,
      ...this.httpAuthHeaderPart(token),
    });
  }

  publishComment(
    content: string,
    musicId: number,
    token: string
  ): Promise<CommentsDto | null> {
    return this.POST<CommentsDto | null>(
      'comments',
      {
        content,
        musicId,
      },
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }

  fetchCommentsByMusicId(
    musicId: number,
    limit: number,
    offset: number
  ): Promise<CommentsDto[]> {
    return this.GET<CommentsDto[]>('/comments/music/' + musicId, {
      limit,
      offset,
    });
  }

  addMusicToPlaylist(
    playlistId: number,
    musicId: number,
    token: string
  ): Promise<void> {
    return this.POST<void>(
      `/playlists/${playlistId}/add/${musicId}`,
      {},
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }
  removeMusicFromPlaylist(
    playlistId: number,
    musicId: number,
    token: string
  ): Promise<void> {
    return this.POST<void>(
      `/playlists/${playlistId}/remove/${musicId}`,
      {},
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }

  async fetchUserPlaylistsWithMusics(
    userId: number,
    limit: number,
    offset: number
  ): Promise<(PlaylistsDto & { musics: MusicDto[] })[]> {
    const userPlaylists = await this.GET<PlaylistsDto[]>(
      `playlists/user/${userId}`,
      { limit, offset }
    );

    return await Promise.all(
      userPlaylists.map(
        async (playlist): Promise<PlaylistsDto & { musics: MusicDto[] }> => {
          // TODO: Change music limit & offset.
          const musics = await this.GET<MusicDto[]>(
            `music/playlist/${playlist.playlistID}`,
            { limit: -1, offset: 0 }
          );

          return { ...playlist, musics };
        }
      )
    );
  }

  async fetchMusicBufferBlock(
    musicId: number,
    blocknumber: number,
    Nblocks: number
  ): Promise<ArrayBufferLike> {
    try {
      const ret = await this.GET<{ [key: string]: number }>(
        `/music/${musicId}/mpeg-block`,
        {
          blocknumber,
          nblocks: Nblocks,
        },
        this.BASIC_HEADER,
        false
      );

      const u8intArray = new Uint8Array(Object.values(ret));
      const arrayBuffer = u8intArray.buffer;

      return arrayBuffer;
    } catch (error: any) {
      throw new Error(error.message);
    }
  }

  fetchArtistById(artistId: number): Promise<ArtistsDto | null> {
    return this.GET<ArtistsDto | null>('/artists/' + artistId);
  }

  searchByText(
    text: string,
    limit: number,
    offset: number
  ): Promise<SearchResultDto> {
    return this.GET<SearchResultDto>('/search/', {
      limit,
      offset,
      q: text,
    });
  }
  async login({
    email,
    password,
  }: {
    email: string;
    password: string;
  }): Promise<{ token: string; user: UsersDto }> {
    let token = '';
    try {
      const res = await this.POST<{ access_token: string }>(`auth/login`, {
        email,
        password,
      });

      token = res.access_token;
    } catch (error: any) {
      throw new Error(error.message);
    }

    let user: UsersDto;
    try {
      user = await this.GET<UsersDto>(
        `auth/whoami`,
        {},
        {
          ...this.BASIC_HEADER,
          ...this.httpAuthHeaderPart(token),
        }
      );
    } catch (error: any) {
      throw new Error('Encounterd an unexpected error. Try again.');
    }

    return {
      token,
      user,
    };
  }
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
  }): Promise<UsersDto> {
    return this.POST<UsersDto>(`auth/register`, {
      lastname: lastName,
      firstname: firstName,
      email,
      password,
      username,
    });
  }

  createPlaylist(
    { name, description }: { name: string; description: string },
    token: string
  ): Promise<PlaylistsDto> {
    return this.POST<PlaylistsDto>(
      'playlists',
      { name, description },
      {
        ...this.BASIC_HEADER,
        ...this.httpAuthHeaderPart(token),
      }
    );
  }
}
