import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { CommentsDto } from 'src/types/api-dto/CommentsDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-user-menu',
  templateUrl: './user-page.component.html',
  host: {
    class: 'h-full w-full',
  },
  styleUrls: ['./user-page.component.scss'],
})
export class UserPageComponent implements OnInit {
  protected userInfo: UsersDto | null = null;
  protected userPlaylists: PlaylistsDto[] = [];
  protected userSubscriptions: UsersDto[] = [];
  protected userComments: CommentsDto[] = [];

  protected loadingPlaylists: boolean = false;
  protected loadingSubscriptions: boolean = false;
  protected loadingComments: boolean = false;

  protected isSubscribe: boolean | null = null;

  constructor(
    private apiHandler: ApiHandlerService,
    protected authService: AuthService,
    private eventBus: EventBusService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  async ngOnInit(): Promise<void> {
    this.route.params.subscribe(async (routeParams) => {
      await this.loadData(routeParams['id']);
    });
  }

  redirectToPlaylist(playlistId: number): void {
    this.router.navigate(['playlist', playlistId]);
  }

  redirectToUser(userId: number): void {
    this.router.navigate(['user', userId]);
  }

  private async loadData(userIdStr: string) {
    this.userInfo = null;
    this.userPlaylists = [];
    this.userSubscriptions = [];
    this.userComments = [];

    this.loadingPlaylists = true;
    this.loadingComments = true;
    this.loadingSubscriptions = true;

    if (!userIdStr) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          'Cannot properly read id specified in url. Redirect to playlist menu.'
        )
      );
      this.router.navigate(['']);
      return;
    }

    const userId = Number.parseInt(userIdStr);
    this.userInfo = await this.apiHandler.fetchUserById(userId);

    if (!this.userInfo) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          "Queried user doesn't exists. Redirect to home menu."
        )
      );
      this.router.navigate(['/']);
      return;
    }

    this.userPlaylists = await this.apiHandler.fetchPlaylistByOwnerId(
      this.userInfo.userID
    );
    this.loadingPlaylists = false;

    this.userSubscriptions = await this.apiHandler.fetchSubscriptionsByUserId(
      this.userInfo.userID
    );
    this.loadingSubscriptions = false;

    this.userComments = await this.apiHandler.fetchCommentsByWritterId(
      this.userInfo.userID
    );
    this.loadingComments = false;

    const subState = await this.apiHandler.fetchSubscribeState(
      this.userInfo?.userID || -1,
      this.authService.getToken() as string
    );

    this.isSubscribe = this.authService.isLoggedIn() && subState;
  }

  async subscribe() {
    if (!this.authService.isLoggedIn() || !this.userInfo) return;

    this.apiHandler
      .subscribe(this.userInfo?.userID, this.authService.getToken() as string)
      .then(() => {
        this.isSubscribe = true;
      })
      .catch((err) => {
        this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
      });
  }

  async unsubscribe() {
    if (!this.authService.isLoggedIn() || !this.userInfo) return;

    this.apiHandler
      .unsubscribe(this.userInfo?.userID, this.authService.getToken() as string)
      .then(() => {
        this.isSubscribe = false;
      })
      .catch((err) => {
        this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
      });
  }
}
