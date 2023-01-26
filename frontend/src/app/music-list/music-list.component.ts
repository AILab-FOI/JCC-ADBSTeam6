import {
  Component,
  ElementRef,
  EventEmitter,
  Input,
  OnInit,
  Output,
  Renderer2,
  ViewChild,
} from '@angular/core';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-music-list',
  templateUrl: './music-list.component.html',
  styleUrls: ['./music-list.component.scss'],
})
export class MusicListComponent {
  @Input('musics') musics!: MusicDto[];
  @Input('loading') loading!: boolean;

  @Output('play') playEvent = new EventEmitter<number>();
  @Output('clear-queue') clearQueueEvent = new EventEmitter<void>();
  @Output('like-music') likeMusicEvent = new EventEmitter<number>();
  @Output('add-music-playlists') addMusicToPlaylistsEvent = new EventEmitter<{
    music: number;
    playlists: number[];
  }>();

  protected displayActionMenu = false;
  private associatedMusicId = -1;

  protected displayPlaylistsMenu = false;
  protected selectedPlaylists: number[] = [];
  protected loadingPlaylist = false;
  protected userPlaylists: PlaylistsDto[] = [];
  private originalPlaylists: number[] = [];

  protected liked: { [key: number]: boolean } = {};

  constructor(
    private apiHandler: ApiHandlerService,
    private eventBus: EventBusService,
    protected authService: AuthService
  ) {}

  async fetchLikeState(musicId: number) {
    if (!this.authService.isLoggedIn()) {
      this.liked[musicId] = false;
      return;
    }

    if (!Object.keys(this.liked).includes(musicId.toString())) {
      const res = await this.apiHandler
        .fetchLikeState(musicId, this.authService.getToken() as string)
        .catch((err) => {
          this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
        });

      if (!res) {
        this.liked[this.associatedMusicId] = false;
        return;
      }

      this.liked[this.associatedMusicId] = res;
    }
  }

  get associatedMusicIsLiked() {
    return (
      Object.keys(this.liked).includes(this.associatedMusicId.toString()) &&
      this.liked[this.associatedMusicId]
    );
  }

  get actionMenuStyle(): string {
    const idx = this.musics
      .map((a) => a.musicID)
      .indexOf(this.associatedMusicId);
    const linePxHeight = 40;
    return `transform: translateY(${idx * linePxHeight}px) translateX(-40px)`;
  }

  play(musicId: number) {
    this.eventBus.emit(
      new EventData(EventDataEnum.ADD_MUSIC_TO_QUEUE, musicId)
    );
  }

  openActionMenu(associatedMusic: number) {
    if (this.displayActionMenu) {
      this.displayActionMenu = false;
      associatedMusic = -1;
      return;
    }

    this.fetchLikeState(associatedMusic);

    this.displayActionMenu = true;
    this.associatedMusicId = associatedMusic;
  }

  actionPlayNow() {
    this.eventBus.emit(new EventData(EventDataEnum.CLEAR_MUSIC_QUEUE, null));

    this.play(this.associatedMusicId);
  }

  actionPlayAfter() {
    this.play(this.associatedMusicId);
  }

  actionLike() {
    if (!this.authService.isLoggedIn()) return;
    if (!this.associatedMusicIsLiked) {
      this.apiHandler
        .like(this.associatedMusicId, this.authService.getToken() as string)
        .then(() => {
          this.liked[this.associatedMusicId] = true;
        })
        .catch((err) => {
          this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
        });
    } else {
      this.apiHandler
        .unlike(this.associatedMusicId, this.authService.getToken() as string)
        .then(() => {
          this.liked[this.associatedMusicId] = false;
        })
        .catch((err) => {
          this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
        });
    }

    this.likeMusicEvent.emit(this.associatedMusicId);
  }

  actionChangePlaylist() {
    if (!this.authService.isLoggedIn()) return;
    for (let playlistId of this.selectedPlaylists) {
      if (!this.originalPlaylists.includes(playlistId)) {
        this.apiHandler
          .addMusicToPlaylist(
            playlistId,
            this.associatedMusicId,
            this.authService.getToken() as string
          )
          .catch((err) => {
            this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
          });
      } else {
        this.apiHandler
          .removeMusicFromPlaylist(
            playlistId,
            this.associatedMusicId,
            this.authService.getToken() as string
          )
          .catch((err) => {
            this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
          });
      }
    }

    this.addMusicToPlaylistsEvent.emit({
      music: this.associatedMusicId,
      playlists: this.selectedPlaylists,
    });

    this.actionHidePlaylistsMenu();
    this.displayActionMenu = false;
  }

  actionAddPlaylistToSelection(playlistId: number) {
    if (this.selectedPlaylists.includes(playlistId)) {
      this.selectedPlaylists.splice(
        this.selectedPlaylists.indexOf(playlistId),
        1
      );
      return;
    }
    this.selectedPlaylists.push(playlistId);
  }

  async actionDisplayPlaylistsMenu() {
    if (!this.authService.isLoggedIn()) return;

    this.selectedPlaylists = [];
    this.displayPlaylistsMenu = true;
    this.loadingPlaylist = true;

    const user = this.authService.getUser() as UsersDto;
    let req = await this.apiHandler.fetchUserPlaylistsWithMusics(
      user.userID,
      -1,
      0
    );

    this.selectedPlaylists = req
      .filter((a) =>
        a.musics.map((b) => b.musicID).includes(this.associatedMusicId)
      )
      .map((a) => a.playlistID);
    this.originalPlaylists = this.selectedPlaylists;

    this.userPlaylists = req.map((a) => {
      let { musics: _, ...playlist } = a;
      return playlist;
    });

    this.loadingPlaylist = false;
  }

  actionHidePlaylistsMenu() {
    this.displayPlaylistsMenu = false;
  }
}
