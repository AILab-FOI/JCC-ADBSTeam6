import { Injectable } from '@angular/core';
import { range } from 'rxjs';
import { choiceN } from 'src/mockHelpers';
import { ArtistsDto } from 'src/types/api-dto/ArtistsDto';
import { CommentsDto } from 'src/types/api-dto/CommentsDto';
import { FullMusicDto } from 'src/types/api-dto/FullMusicDto';
import { GenresDto } from 'src/types/api-dto/GenresDto';
import { MusicArtistsDto } from 'src/types/api-dto/MusicArtistsDto';
import { MusicCreateDto } from 'src/types/api-dto/MusicCreateDto';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { MusicGenreDto } from 'src/types/api-dto/MusicGenreDto';
import { MusicPlaylistDto } from 'src/types/api-dto/MusicPlaylistDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { RolesDto } from 'src/types/api-dto/RolesDto';
import { SearchResultDto } from 'src/types/api-dto/SearchResultDto';
import { SubscriptionsDto } from 'src/types/api-dto/SubscriptionsDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { IApiHandlerService } from './i-api-handler.service';
const mp3Parser = require('mp3-parser');

const users = [
  {
    userID: 1,
    username: 'CJin362',
    password: 'IUtt183',
    email: 'Kassie.Rakestraw105@example.org',
    firstName: 'Suzann',
    lastName: 'Lavrinov',
    Roles_roleID: 2,
  },
  {
    userID: 2,
    username: 'GStr155',
    password: 'JMcT305',
    email: 'Jemimah.Osmund225@example.org',
    firstName: 'Franz',
    lastName: 'Lowy',
    Roles_roleID: 1,
  },
  {
    userID: 3,
    username: 'CRea7',
    password: 'RBun191',
    email: 'Liuka.Roughan423@example.org',
    firstName: 'Benyamin',
    lastName: 'Jinkins',
    Roles_roleID: 2,
  },
];

const mockData: {
  roles: RolesDto[];
  users: (UsersDto & { password: string })[];
  subscriptions: SubscriptionsDto[];
  musics: MusicDto[];
  comments: CommentsDto[];
  artists: ArtistsDto[];
  genres: GenresDto[];
  playlists: PlaylistsDto[];
  music_artists: MusicArtistsDto[];
  music_genres: MusicGenreDto[];
  music_playlists: MusicPlaylistDto[];
} = {
  roles: [
    { roleID: 1, name: 'admin' },
    { roleID: 2, name: 'user' },
  ],
  users,
  subscriptions: [
    {
      userID: 1,
      subscribeToID: 2,
    },
  ],
  musics: [
    {
      musicID: 1,
      title: 'upnmklmhgx',
      description: 'cmavsucfthdaximfgmsrtymnlzwoeliukykvlpuqlbksdrnhzd',
      publicationDate: '8-11-2005',
      turnOffComments: false,
      duration: '3:41',
      Users_userID: 1,
      genres: [],
      artists: [],
    },
    {
      musicID: 2,
      title: 'hizliunoti',
      description: 'qvigmfqfrqrqddthknieprmongkxuydpfqgptldotwdyhoskrl',
      publicationDate: '9-21-2003',
      turnOffComments: false,
      duration: '2:18',
      Users_userID: 1,
      genres: [],
      artists: [],
    },
    {
      musicID: 3,
      title: 'mcuzoapboi',
      description: 'taptwmwphbnbsqigcxxeidtumvtoxrkkwskwepbkkwgurbveyz',
      publicationDate: '2-22-2011',
      turnOffComments: false,
      duration: '1:58',
      Users_userID: 1,
      genres: [],
      artists: [],
    },
    {
      musicID: 4,
      title: 'shfsarcwhf',
      description: 'czlgpbwhnwtkzhmzewxqscqeylthxhrmvkzvcuczxzmdksetny',
      publicationDate: '2-19-1993',
      turnOffComments: false,
      duration: '5:19',
      Users_userID: 1,
      genres: [],
      artists: [],
    },
    {
      musicID: 5,
      title: 'otuzzdtgnv',
      description: 'qxadowvhyyfdocckhnraueqcffgpwooitpmeouuzyxqgfwplrv',
      publicationDate: '4-18-1983',
      turnOffComments: false,
      duration: '3:55',
      Users_userID: 3,
      genres: [],
      artists: [],
    },
    {
      musicID: 6,
      title: 'opbbnnmfre',
      description: 'izqeqoroteqkupegrmrcpuvgtmuzupgixvkkelmygdvtfowibg',
      publicationDate: '10-26-1997',
      turnOffComments: false,
      duration: '3:06',
      Users_userID: 2,
      genres: [],
      artists: [],
    },
    {
      musicID: 7,
      title: 'ngfncaiine',
      description: 'vszalwgknwfrbvlznxgqyfbqqiznnnnlipkskknfqaparqfypn',
      publicationDate: '1-12-2002',
      turnOffComments: false,
      duration: '1:43',
      Users_userID: 1,
      genres: [],
      artists: [],
    },
    {
      musicID: 8,
      title: 'nguyptqfed',
      description: 'klnmmipykoelmxgxagvoayczqmyndaeqkowyzrznqlpqkhefqf',
      publicationDate: '10-16-1986',
      turnOffComments: false,
      duration: '5:52',
      Users_userID: 3,
      genres: [],
      artists: [],
    },
    {
      musicID: 9,
      title: 'gnyatvavxa',
      description: 'yphcyybzdkdidpiytltrberiltqezcefcnxvdumdwdxsekhqwc',
      publicationDate: '12-27-1994',
      turnOffComments: false,
      duration: '5:05',
      Users_userID: 3,
      genres: [],
      artists: [],
    },
    {
      musicID: 10,
      title: 'bgtoggbpvt',
      description: 'dlbpamnuptqudxvdfaykvtifidzkdvflhzekmmobrfkoulnkmg',
      publicationDate: '10-28-2001',
      turnOffComments: false,
      duration: '5:07',
      Users_userID: 2,
      genres: [],
      artists: [],
    },
  ] as MusicDto[],
  comments: [
    { commentID: 1, content: 'vluqdfakw', Users_userID: 1, Music_musicID: 4 },
    {
      commentID: 2,
      content: 'rswgzcocpsvaqphdnvxerqpofg',
      Users_userID: 2,
      Music_musicID: 3,
    },
    { commentID: 3, content: 'guqlaefhdi', Users_userID: 3, Music_musicID: 7 },
    {
      commentID: 4,
      content: 'ihivvzksfehqnvalutpxlrqsbkbvdtxdtpqdeyxpnofagt',
      Users_userID: 2,
      Music_musicID: 2,
    },
    {
      commentID: 5,
      content: 'dxiuukvyiiqfwxcmdfct',
      Users_userID: 1,
      Music_musicID: 8,
    },
    { commentID: 6, content: 'bnucghacmq', Users_userID: 3, Music_musicID: 6 },
  ],
  artists: [
    { artistID: 1, name: 'LMec385' },
    { artistID: 2, name: 'SFri42' },
    { artistID: 3, name: 'BTat485' },
  ],
  genres: [
    { tagID: 1, name: 'LGoo392' },
    { tagID: 2, name: 'OBre65' },
  ],
  playlists: [
    {
      playlistID: 1,
      name: 'Playlist-8',
      description: 'vieuuphcghsvlyydternsvyfldinclgubpcgrsbuwdxqvgty',
      user: users[1],
    },
    {
      playlistID: 2,
      name: 'Playlist-71',
      description: 'dqwvkkuilpxogtlbbk',
      user: users[1],
    },
    {
      playlistID: 3,
      name: 'Playlist-123',
      description: 'yesgnbnfgcgwqnzv',
      user: users[3],
    },
    {
      playlistID: 4,
      name: 'Playlist-169',
      description: 'xfboengtnun',
      user: users[3],
    },
    {
      playlistID: 5,
      name: 'Playlist-190',
      description: 'uvbqhmqhkacrnddlhmluqhzodltigrmzcoxeuk',
      user: users[3],
    },
    {
      playlistID: 6,
      name: 'Likes',
      description: 'Liked music of CJin362.',
      user: users[1],
    },
    {
      playlistID: 7,
      name: 'Likes',
      description: 'Liked music of GStr155.',
      user: users[2],
    },
    {
      playlistID: 8,
      name: 'Likes',
      description: 'Liked music of CRea7.',
      user: users[3],
    },
  ],
  music_artists: [
    { Music_musicID: 4, Artists_artistID: 2 },
    { Music_musicID: 8, Artists_artistID: 2 },
    { Music_musicID: 10, Artists_artistID: 3 },
    { Music_musicID: 8, Artists_artistID: 1 },
    { Music_musicID: 9, Artists_artistID: 1 },
    { Music_musicID: 2, Artists_artistID: 2 },
    { Music_musicID: 2, Artists_artistID: 1 },
    { Music_musicID: 4, Artists_artistID: 3 },
    { Music_musicID: 10, Artists_artistID: 3 },
    { Music_musicID: 8, Artists_artistID: 2 },
  ],
  music_genres: [
    { Music_musicID: 3, Genre_genreID: 2 },
    { Music_musicID: 3, Genre_genreID: 1 },
    { Music_musicID: 1, Genre_genreID: 1 },
    { Music_musicID: 1, Genre_genreID: 1 },
    { Music_musicID: 8, Genre_genreID: 1 },
    { Music_musicID: 8, Genre_genreID: 2 },
    { Music_musicID: 4, Genre_genreID: 2 },
    { Music_musicID: 10, Genre_genreID: 2 },
    { Music_musicID: 10, Genre_genreID: 2 },
    { Music_musicID: 7, Genre_genreID: 2 },
  ],
  music_playlists: [
    { Playlists_playlistID: 5, Music_musicID: 5, order: 1 },
    { Playlists_playlistID: 1, Music_musicID: 5, order: 1 },
    { Playlists_playlistID: 2, Music_musicID: 4, order: 1 },
    { Playlists_playlistID: 3, Music_musicID: 3, order: 1 },
    { Playlists_playlistID: 1, Music_musicID: 1, order: 2 },
    { Playlists_playlistID: 3, Music_musicID: 2, order: 2 },
  ],
};

let mockAudioBuffer: ArrayBuffer;
fetch('http://localhost:4200/assets/audio.mp3')
  .then((data) => data.arrayBuffer())
  .then((a) => (mockAudioBuffer = a));

let mockAudioBufferBlob: Blob;
fetch('http://localhost:4200/assets/audio.mp3')
  .then((data) => data.blob())
  .then((a) => (mockAudioBufferBlob = a));

@Injectable({
  providedIn: 'root',
})
export class MockApiHandlerService implements IApiHandlerService {
  private musicBlocksize: number;
  private tokenList: { token: string; userID: number }[] = [];

  constructor() {
    this.musicBlocksize = 4096;
  }
  async increaseViewsCounter(musicId: number): Promise<void> {}
  async createPlaylist(
    { name, description }: { name: string; description: string },
    token: string
  ): Promise<PlaylistsDto> {
    return mockData.playlists[0];
  }
  async fetchMusicOfArtist(artistId: number): Promise<MusicDto[]> {
    return [];
  }
  async fetchMusicLikeNumber(musicId: number): Promise<number> {
    return 0;
  }
  async fetchMusicViewNumber(musicId: number): Promise<number> {
    return 0;
  }

  private getUserIdFromToken(token: string): number {
    const connectedUsers = this.tokenList.filter((a) => a.token === token);
    if (connectedUsers.length === 0) {
      throw {
        status: 403,
        message: 'You must be authentificated to subscribe to a user.',
      };
    }
    return connectedUsers[0].userID;
  }

  private getLikesPlaylistIdOfUser(userId: number): PlaylistsDto {
    const likePlaylists = mockData.playlists.filter(
      (a) => a.user.userID === userId && a.name === 'Likes'
    );
    if (likePlaylists.length !== 1) {
      throw {
        status: 400,
        message:
          'Impossible to find a correct playlist corresponding to liked musics.',
      };
    }

    return likePlaylists[0];
  }

  async publishComment(
    content: string,
    musicId: number,
    token: string
  ): Promise<CommentsDto | null> {
    return new Promise(async (r) => {
      await this.sleep(Math.random() * 1 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return r(null);
      }

      const comment: CommentsDto = {
        content,
        Music_musicID: musicId,
        Users_userID: userId,
        commentID: Math.max(...mockData.comments.map((a) => a.commentID)) + 1,
      };
      mockData.comments.push(comment);

      return r(comment);
    });
  }

  async addMusicToPlaylist(
    playlistId: number,
    musicId: number,
    token: string
  ): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 1 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {}

      let playlists = mockData.playlists.filter(
        (a) => a.playlistID === playlistId
      );
      if (playlists.length === 0) {
        return errf("Playlist don't exists.");
      }
      let playlist = playlists[0];
      if (playlist.user.userID !== userId) {
        return errf("You're not the owner of this playlist.");
      }

      const musics = mockData.music_playlists.filter(
        (a) => a.Playlists_playlistID === playlistId
      );
      if (musics.filter((a) => a.Music_musicID === musicId).length > 0) {
        return errf('This music is already in the playlist.');
      }

      mockData.music_playlists.push({
        Playlists_playlistID: playlistId,
        Music_musicID: musicId,
        order: Math.max(...musics.map((a) => a.order)) + 1,
      });

      return r();
    });
  }

  async removeMusicFromPlaylist(
    playlistId: number,
    musicId: number,
    token: string
  ): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 1 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {}

      let playlists = mockData.playlists.filter(
        (a) => a.playlistID === playlistId
      );
      if (playlists.length === 0) {
        return errf("Playlist don't exists.");
      }
      let playlist = playlists[0];
      if (playlist.user.userID !== userId) {
        return errf("You're not the owner of this playlist.");
      }

      let idx = -1;
      for (let i = 0; i < mockData.music_playlists.length; i++) {
        let music = mockData.music_playlists[i];
        if (
          music.Playlists_playlistID === playlist.playlistID &&
          music.Music_musicID === musicId
        ) {
          idx = i;
          break;
        }
      }

      if (idx < 0) {
        return errf('This music is not in the playlist.');
      }

      mockData.music_playlists.splice(idx, 1);

      return r();
    });
  }

  async fetchLikeState(musicId: number, token: string): Promise<boolean> {
    return new Promise(async (r) => {
      await this.sleep(Math.random() * 1 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return r(false);
      }

      let likePlaylist: PlaylistsDto;
      try {
        likePlaylist = this.getLikesPlaylistIdOfUser(userId);
      } catch (error) {
        return r(false);
      }

      const musicIds = mockData.music_playlists
        .filter((a) => a.Playlists_playlistID === likePlaylist.playlistID)
        .map((a) => a.Music_musicID);
      if (musicIds.includes(musicId)) {
        return r(true);
      }

      return r(false);
    });
  }

  async like(musicId: number, token: string): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.5 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      let likePlaylist: PlaylistsDto;
      try {
        likePlaylist = this.getLikesPlaylistIdOfUser(userId);
      } catch (data: any) {
        return r(data.message);
      }

      const musicIds = mockData.music_playlists.filter(
        (a) => a.Playlists_playlistID === likePlaylist.playlistID
      );

      if (musicIds.map((a) => a.Music_musicID).includes(musicId)) {
        return errf("Can't like, connected user already liked this music.");
      }

      mockData.music_playlists.push({
        Playlists_playlistID: likePlaylist.playlistID,
        Music_musicID: musicId,
        order: Math.max(...musicIds.map((a) => a.order)) + 1,
      });
      return r();
    });
  }

  async unlike(musicId: number, token: string): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.5 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      let likePlaylist: PlaylistsDto;
      try {
        likePlaylist = this.getLikesPlaylistIdOfUser(userId);
      } catch (data: any) {
        return r(data.message);
      }

      let idx = -1;
      for (let i = 0; i < mockData.music_playlists.length; i++) {
        let music = mockData.music_playlists[i];
        if (
          music.Playlists_playlistID === likePlaylist.playlistID &&
          music.Music_musicID === musicId
        ) {
          idx = i;
          break;
        }
      }

      if (idx < 0) {
        return errf("Can't unlike, connected user doesn't like this music.");
      }

      mockData.music_playlists.splice(idx, 1);
      return r();
    });
  }

  async fetchSubscribeState(
    subscribeTo: number,
    token: string
  ): Promise<boolean> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.5 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      r(
        mockData.subscriptions.filter(
          (a) => a.userID === userId && a.subscribeToID === subscribeTo
        ).length > 0
      );
    });
  }

  async subscribe(subscribeTo: number, token: string): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.1 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      if (
        mockData.subscriptions.filter(
          (a) => a.userID === userId && a.subscribeToID === subscribeTo
        ).length > 0
      ) {
        return errf(
          "Can't subscribe, connected user already follow this user."
        );
      }

      mockData.subscriptions.push({
        subscribeToID: subscribeTo,
        userID: userId,
      });
      return r();
    });
  }

  async unsubscribe(subscribeTo: number, token: string): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.1 * 1000);

      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      let idx = -1;
      for (let i = 0; i < mockData.subscriptions.length; i++) {
        let sub = mockData.subscriptions[i];
        if (sub.subscribeToID === subscribeTo && sub.userID === userId) {
          idx = i;
          break;
        }
      }

      if (idx < 0) {
        return errf(
          "Can't unsubscribe, connected user needs to follow the user."
        );
      }

      mockData.subscriptions.splice(idx, 1);
      return r();
    });
  }

  async fetchCommentsByWritterId(writterId: number): Promise<CommentsDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 1 * 1000);

      const comments = mockData.comments.filter(
        (a) => a.Users_userID === writterId
      );
      return r(comments);
    });
  }

  async fetchPlaylistByOwnerId(ownerId: number): Promise<PlaylistsDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 1 * 1000);

      const playlists = mockData.playlists.filter(
        (a) => a.user.userID === ownerId
      );
      return r(playlists);
    });
  }

  async fetchSubscriptionsByUserId(userId: number): Promise<UsersDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 1 * 1000);

      const subs = mockData.subscriptions.filter((a) => a.userID === userId);
      const users: UsersDto[] = [];

      for (let s of subs) {
        const u = mockData.users.filter((a) => a.userID === s.subscribeToID);

        if (u.length > 0) {
          users.push(u[0]);
        }
      }

      return r(users);
    });
  }

  async fetchUserById(userId: number): Promise<UsersDto | null> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 1 * 1000);

      const users = mockData.users.filter((a) => a.userID === userId);
      if (users.length === 0) return r(null);

      return r(users[0]);
    });
  }

  async fetchArtistById(artistId: number): Promise<ArtistsDto | null> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 1 * 1000);
      const artists = mockData.artists.filter((a) => a.artistID === artistId);
      if (artists.length === 0) return r(null);

      return r(artists[0]);
    });
  }

  async searchByText(text: string, limit: number): Promise<SearchResultDto> {
    return new Promise(async (r, _) => {
      const ret: SearchResultDto = {
        titles: [],
        artists: [],
        playlists: [],
        users: [],
      };

      if (text === '') {
        return r(ret);
      }

      // await this.sleep(Math.random() * 1 * 1000);
      ret.titles = mockData.musics.filter((a) =>
        a.title.toLowerCase().includes(text.toLowerCase())
      );
      ret.artists = mockData.artists.filter((a) =>
        a.name.toLowerCase().includes(text.toLowerCase())
      );
      ret.playlists = mockData.playlists.filter((a) =>
        a.name.toLowerCase().includes(text.toLowerCase())
      );
      ret.users = mockData.users.filter((a) =>
        a.username.toLowerCase().includes(text.toLowerCase())
      );

      return r(ret);
    });
  }

  async fetchMusicBufferBlock(
    musicId: number,
    blocknumber: number,
    Nblocks: number
  ): Promise<ArrayBuffer> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.2 * 1000);
      if (!mockAudioBuffer) return errf(new Error('[500] Mock audio error'));
      // const buffer = mp3Parser.readId3v2Tag(new DataView(mockAudioBuffer)).frames.filter((a: {name: string}) => a.name === "Private frame")[0].

      // r(buffer);
    });
  }

  async fetchMusicBufferBlockBlob(
    musicId: number,
    blocknumber: number,
    Nblocks: number
  ): Promise<ArrayBuffer> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.2 * 1000);
      if (!mockAudioBuffer) return errf(new Error('[500] Mock audio error'));
      const dataView = new DataView(mockAudioBuffer);
      const startAt = mp3Parser.readId3v2Tag(dataView)._section.byteLength;
      let i = startAt;
      let start = mp3Parser.readFrame(dataView, i);
      while (!start) {
        i++;
        start = mp3Parser.readFrame(dataView, i);
      }

      // console.log(start);

      for (let j = 0; j < blocknumber; j++) {
        start = mp3Parser.readFrame(dataView, start._section.nextFrameIndex);
        // console.log(start);
      }

      let end = start;
      for (
        let j = 0;
        j < Nblocks &&
        mp3Parser.readFrame(dataView, end._section.nextFrameIndex);
        j++
      ) {
        end = mp3Parser.readFrame(dataView, end._section.nextFrameIndex);
        // console.log(end);
      }

      r(
        mockAudioBuffer.slice(
          start._section.offset,
          end._section.offset + end._section.byteLength
        )
      );
    });
  }

  async submitMusic(
    {
      title,
      description,
      artistIds,
      genreIds,
      turnOffComments,
    }: MusicCreateDto,
    file: File,
    token: string
  ): Promise<number> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 3 * 1000);
      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      const music: MusicDto = {
        title,
        description,
        turnOffComments,
        publicationDate: new Date().toDateString(),
        duration: '0:00',
        Users_userID: userId,
        musicID: mockData.musics.length + 1,
        genres: [],
        artists: [],
      };
    });
  }

  async fetchAllArtists(
    limit: number = -1,
    offset: number = 0
  ): Promise<ArtistsDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 0.5 * 1000);
      return r(mockData.artists);
    });
  }

  async deleteComment(commentId: number, token: string): Promise<void> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.5 * 1000);
      let userId = -1;
      try {
        userId = this.getUserIdFromToken(token);
      } catch (data: any) {
        return errf(data.message);
      }

      const comments = mockData.comments.filter(
        (a) => a.commentID === commentId
      );
      if (comments.length === 0) {
        return errf("Can't delete the comment. It don't exists.");
      }

      const comment = comments[0];
      if (comment.Users_userID !== userId) {
        return errf("Can't delete the comment. You're not its owner.");
      }

      const idx = mockData.comments.map((a) => a.commentID).indexOf(commentId);
      mockData.comments.splice(idx, 1);

      return r();
    });
  }

  async fetchMusicTotalNumberOfBlock(musicId: number): Promise<number> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 0.1 * 1000);

      if (!mockAudioBuffer) return errf(new Error('[500] Mock audio error'));
      r(mockAudioBuffer.byteLength);
    });
  }

  getFetchedMusicBlocksize(): number {
    return this.musicBlocksize;
  }

  async fetchMusicById(musicId: number): Promise<MusicDto | null> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 0.2 * 1000);

      let musics = mockData.musics.filter((a) => a.musicID === musicId);
      if (musics.length === 0) return r(null);

      return r(musics[0]);
    });
  }

  private async sleep(time: number): Promise<void> {
    return new Promise((r, _) => {
      const timer = setTimeout(() => {
        r();
        clearTimeout(timer);
      }, time);
    });
  }

  async fetchPopulatedMusic(musicId: number): Promise<FullMusicDto | null> {
    return new Promise(async (r) => {
      await this.sleep(Math.random() * 3 * 1000);

      const musics = mockData.musics.filter((a) => a.musicID === musicId);
      if (musics.length === 0) return r(null);
      const music = musics[0];

      const genreIds = mockData.music_genres
        .filter((a) => a.Music_musicID === musicId)
        .map((a) => a.Genre_genreID);
      const artistIds = mockData.music_artists
        .filter((a) => a.Music_musicID === musicId)
        .map((a) => a.Artists_artistID);

      return r({
        ...music,
        genres: mockData.genres.filter((a) => genreIds.includes(a.tagID)),
        artists: mockData.artists.filter((a) => artistIds.includes(a.artistID)),
      });
    });
  }

  async fetchCommentsByMusicId(
    musicId: number,
    limit: number = -1,
    offset: number = 0
  ): Promise<CommentsDto[]> {
    return new Promise(async (r) => {
      await this.sleep(Math.random() * 1 * 1000);

      return r(mockData.comments.filter((a) => a.Music_musicID === musicId));
    });
  }

  async fetchPlaylistById(playlistId: number): Promise<PlaylistsDto | null> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 0.5 * 1000);
      let filtered = mockData.playlists.filter(
        (a) => a.playlistID === playlistId
      );
      if (filtered.length === 0) return r(null);
      else r(filtered[0]);
    });
  }

  async fetchMusicPlaylistById(playlistId: number): Promise<MusicDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 3 * 1000);

      let playlistMusic = mockData.music_playlists.filter(
        (a) => a.Playlists_playlistID === playlistId
      );
      let musicsId = playlistMusic.map((a) => a.Music_musicID);

      // TODO handle order

      r(mockData.musics.filter((a) => musicsId.includes(a.musicID)));
    });
  }

  async fetchAllPlaylist(
    limit: number = -1,
    offset: number = 0
  ): Promise<PlaylistsDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 2 * 1000);
      r(mockData.playlists);
    });
  }

  async fetchHitMusic(limit: number, offset: number): Promise<MusicDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 5 * 1000);
      r(choiceN(8, mockData.musics));
    });
  }

  async fetchMusicArtistsById(musicId: number): Promise<ArtistsDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 3 * 1000);
      let artistsId = mockData.music_artists
        .filter((obj) => obj.Music_musicID === musicId)
        .map((a) => a.Artists_artistID);

      r(mockData.artists.filter((obj) => artistsId.includes(obj.artistID)));
    });
  }

  async fetchMusicByGenresId(genreId: number): Promise<MusicDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 3 * 1000);
      let musicsId = mockData.music_genres
        .filter((a) => a.Genre_genreID === genreId)
        .map((a) => a.Music_musicID);

      r(mockData.musics.filter((a) => musicsId.includes(a.musicID)));
    });
  }

  async fetchAllGenres(
    limit: number = -1,
    offset: number = 0
  ): Promise<GenresDto[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 3 * 1000);

      r(mockData.genres);
    });
  }

  async fetchUserPlaylistsWithMusics(
    userId: number,
    limit: number,
    offset: number
  ): Promise<(PlaylistsDto & { musics: MusicDto[] })[]> {
    return new Promise(async (r, _) => {
      await this.sleep(Math.random() * 2 * 1000);
      let playlists = mockData.playlists.filter(
        (a) => a.user.userID === userId
      );

      playlists = playlists.map((p) => {
        const musicId = mockData.music_playlists
          .filter((a) => a.Playlists_playlistID === p.playlistID)
          .map((a) => a.Music_musicID);

        return {
          ...p,
          musics: mockData.musics.filter((a) => musicId.includes(a.musicID)),
        };
      });
    });
  }

  deleteMusic(musicId: number, token: string): Promise<MusicDto | null> {
    throw new Error('Not implemented yet.');
  }

  async login({
    email,
    password,
  }: {
    email: string;
    password: string;
  }): Promise<{ token: string; user: UsersDto }> {
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 2 * 1000);
      const users = mockData.users.filter((a) => a.email === email);
      if (users.length === 0) {
        return errf({
          status: 400,
          message: 'Bad credentials',
        });
      }

      const user = users[0];
      if (user.password !== password) {
        return errf({
          status: 400,
          message: 'Bad credentials',
        });
      }

      const token = 'user-' + user.userID;
      this.tokenList.push({
        token,
        userID: user.userID,
      });
      return r({ token, user });
    });
  }

  async register({
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
    return new Promise(async (r, errf) => {
      await this.sleep(Math.random() * 1 * 1000);
      if (mockData.users.filter((a) => a.email === email).length > 0) {
        return errf({
          status: 400,
          message: 'email already used.',
        });
      }

      if (mockData.users.filter((a) => a.username === username).length > 0) {
        return errf({
          status: 400,
          message: 'username already used.',
        });
      }

      const userRoleId = mockData.roles.filter((a) => a.name === 'user')[0]
        .roleID;
      const user: UsersDto & { password: string } = {
        lastName,
        firstName,
        username,
        email,
        password,
        Roles_roleID: userRoleId,
        userID:
          (mockData.users
            .map((a) => a.userID)
            .sort()
            .at(-1) || 0) + 1,
      };

      mockData.users.push(user);
      r(user);
    });
  }
}
