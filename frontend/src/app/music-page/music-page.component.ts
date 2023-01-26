import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Subscription } from 'rxjs';
import { CommentsDto } from 'src/types/api-dto/CommentsDto';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { MusicStatsEventDto } from 'src/types/socket-dto/MusicStatsEvent.dto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';
import { WebsocketService } from '../websocket.service';
import { WebsocketEventNameEnum } from '../WebsocketEventName.enum';

@Component({
  selector: 'app-music-page',
  templateUrl: './music-page.component.html',
  styleUrls: ['./music-page.component.scss'],
})
export class MusicPageComponent implements OnInit, OnDestroy {
  protected musicInfo?: MusicDto;
  protected comments: CommentsDto[] = [];

  protected like: number = 10;
  protected views: number = 233;
  protected isLike = false;

  private musicStatsObserver?: Subscription;

  protected loadingMusic = false;
  protected loadingComments = false;

  protected commentContent: string = '';

  constructor(
    private apiHandler: ApiHandlerService,
    protected authService: AuthService,
    private router: Router,
    private route: ActivatedRoute,
    private eventBus: EventBusService,
    private websocketService: WebsocketService
  ) {}

  ngOnDestroy(): void {
    this.musicStatsObserver?.unsubscribe();
  }

  async ngOnInit(): Promise<void> {
    this.loadingMusic = true;
    this.loadingComments = true;

    const musicIdStr = this.route.snapshot.paramMap.get('id');
    if (!musicIdStr) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          'Cannot properly read id specified in url. Redirect to home menu.'
        )
      );
      this.router.navigate(['']);
      return;
    }

    const musicId = Number.parseInt(musicIdStr);
    let music = await this.apiHandler.fetchMusicById(musicId);
    if (!music) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          "Queried music doesn't exists. Redirect to home menu."
        )
      );
      this.router.navigate(['']);
      return;
    }
    this.musicInfo = music;
    this.loadingMusic = false;

    this.musicStatsObserver = this.websocketService
      .listen<MusicStatsEventDto>(WebsocketEventNameEnum.MUSIC_STATS)
      .subscribe((data: MusicStatsEventDto) => {
        if (data.musicId === this.musicInfo?.musicID) {
          this.views = data.views;
          this.like = data.likes;
        }
      });
    if (this.musicInfo) {
      this.websocketService.emit(WebsocketEventNameEnum.ASK_MUSIC_STATS, {
        musicId: this.musicInfo.musicID,
      });
    }

    this.updateIsLike();
  }

  async loadNextComments() {
    this.loadingComments = true;
    const limit = 5;
    if (!this.musicInfo) return;

    const comments = await this.apiHandler.fetchCommentsByMusicId(
      this.musicInfo.musicID,
      -1,
      0
    );
    this.comments.push(...comments);
    this.loadingComments = false;
  }

  get isOwner(): boolean {
    if (!this.authService.isLoggedIn() || !this.musicInfo) return false;

    const user = this.authService.getUser() as UsersDto;
    return user.userID === this.musicInfo.Users_userID;
  }

  get genreFormat(): string {
    if (!this.musicInfo) return '';
    return this.musicInfo.genres.map((a) => a.name).join(', ');
  }

  async deleteMusic(): Promise<void> {
    if (!this.isOwner) return;

    if (!this.musicInfo) return;

    this.apiHandler
      .deleteMusic(
        this.musicInfo.musicID,
        this.authService.getToken() as string
      )
      .then((music) => {
        if (!music) return;
        this.eventBus.emit(
          new EventData(
            EventDataEnum.INFO_POPUP,
            `${music.title} have been correctly deleted.`
          )
        );
        this.router.navigate(['/']);
      })
      .catch((err) => {
        this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
      });
  }

  async updateIsLike(): Promise<void> {
    if (!this.authService.isLoggedIn() || !this.musicInfo) {
      this.isLike = false;
      return;
    }

    this.isLike =
      (await this.apiHandler
        .fetchLikeState(
          this.musicInfo.musicID,
          this.authService.getToken() as string
        )
        .catch((err) => {
          this.eventBus.emit(
            new EventData(EventDataEnum.ERROR_POPUP, err.message)
          );
        })) || false;
  }

  actionLikeButton() {
    if (this.isLike) {
      this.unlikeMusic();
    } else {
      this.likeMusic();
    }
  }

  likeMusic() {
    if (!this.authService.isLoggedIn() || !this.musicInfo) return;
    this.apiHandler
      .like(this.musicInfo.musicID, this.authService.getToken() as string)
      .then(() => {
        this.isLike = true;
      })
      .catch((err) => {
        this.eventBus.emit(
          new EventData(EventDataEnum.ERROR_POPUP, err.message)
        );
      });
  }

  unlikeMusic() {
    if (!this.authService.isLoggedIn() || !this.musicInfo) return;
    this.apiHandler
      .unlike(this.musicInfo.musicID, this.authService.getToken() as string)
      .then(() => {
        this.isLike = false;
      })
      .catch((err) => {
        this.eventBus.emit(
          new EventData(EventDataEnum.ERROR_POPUP, err.message)
        );
      });
  }

  playNow() {
    if (!this.musicInfo) return;

    this.eventBus.emit(new EventData(EventDataEnum.CLEAR_MUSIC_QUEUE, null));
    this.eventBus.emit(
      new EventData(EventDataEnum.ADD_MUSIC_TO_QUEUE, this.musicInfo.musicID)
    );
  }

  playAfter() {
    if (!this.musicInfo) return;
    this.eventBus.emit(
      new EventData(EventDataEnum.ADD_MUSIC_TO_QUEUE, this.musicInfo.musicID)
    );
  }

  async publishComment() {
    if (
      !this.authService.isLoggedIn() ||
      !this.musicInfo ||
      this.commentContent === ''
    )
      return;

    this.apiHandler
      .publishComment(
        this.commentContent,
        this.musicInfo.musicID,
        this.authService.getToken() as string
      )
      .then((comment) => {
        if (comment) {
          this.comments.push(comment);
        }
      });
  }
}
