import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-playlist-menu',
  templateUrl: './playlist-menu.component.html',
  host: {
    class: 'h-full w-full',
  },
  styleUrls: ['./playlist-menu.component.scss'],
})
export class PlaylistMenuComponent implements OnInit {
  protected userPlaylists: PlaylistsDto[] = [];
  protected subsPlaylists: PlaylistsDto[] = [];

  protected userPlaylistsLoading = false;
  protected subsPlaylistsLoading = false;

  protected displayAddPlaylistMenu = false;
  protected errorMessage = '';
  protected playlistName = '';
  protected playlistDescription = '';
  protected loadingCreation = false;

  constructor(
    private apiHandler: ApiHandlerService,
    protected authService: AuthService,
    private eventBus: EventBusService,
    private router: Router
  ) {}

  async ngOnInit(): Promise<void> {
    this.userPlaylistsLoading = true;
    this.subsPlaylistsLoading = true;

    if (!this.authService.isLoggedIn()) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          'Should be logged to access /playlists/. Redirected to /.'
        )
      );
      this.router.navigate(['/']);
      return;
    }

    const user = this.authService.getUser() as UsersDto;
    this.userPlaylists = await this.apiHandler.fetchPlaylistByOwnerId(
      user.userID
    );
    this.userPlaylistsLoading = false;

    const subs = await this.apiHandler.fetchSubscriptionsByUserId(user.userID);
    for (let sub of subs) {
      this.subsPlaylists.push(
        ...(await this.apiHandler.fetchPlaylistByOwnerId(sub.userID))
          .filter((a) => a.name === 'Likes')
          .map((a) => ({ ...a, name: sub.username + "'s likes" }))
      );
    }
    this.subsPlaylistsLoading = false;
  }

  redirectToPlaylist(playlistId: number) {
    this.router.navigate(['playlist', playlistId]);
  }

  openAddPlaylistMenu() {
    this.displayAddPlaylistMenu = true;
  }

  closeAddPlaylistMenu() {
    this.displayAddPlaylistMenu = false;
  }

  createPlaylist() {
    this.errorMessage = '';
    if (!this.authService.isLoggedIn()) {
      this.errorMessage = 'You should be logged in.';
      return;
    }

    if (!this.playlistName) {
      this.errorMessage = 'Missing playlist name.';
      return;
    }

    if (!this.playlistDescription) {
      this.errorMessage = 'Missing playlist description.';
      return;
    }

    this.apiHandler
      .createPlaylist(
        { name: this.playlistName, description: this.playlistDescription },
        this.authService.getToken() as string
      )
      .then((playlist) => {
        this.userPlaylists.push(playlist);
        this.closeAddPlaylistMenu();
      })
      .catch((err) => {
        this.errorMessage = err.message;
      });
  }
}
