import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-playlist-page',
  templateUrl: './playlist-page.component.html',
  styleUrls: ['./playlist-page.component.scss'],
})
export class PlaylistPageComponent implements OnInit {
  protected playlist?: PlaylistsDto;
  protected playlistMusic: MusicDto[];
  protected loadingMusic: boolean = false;
  protected imgColor: String = 'bg-blue-600';

  constructor(
    private apiHandler: ApiHandlerService,
    private route: ActivatedRoute,
    private router: Router,
    private eventBus: EventBusService
  ) {
    this.playlist = undefined;
    this.playlistMusic = [];
  }

  async ngOnInit() {
    let playlistIdStr: string | null = this.route.snapshot.paramMap.get('id');
    if (!playlistIdStr) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          'Cannot properly read id specified in url. Redirect to playlist menu.'
        )
      );
      this.router.navigate(['playlist']);
      return;
    }

    const playlistId = Number.parseInt(playlistIdStr);
    let playlist = await this.apiHandler.fetchPlaylistById(playlistId);
    if (!playlist) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          "Queried playlist doesn't exists. Redirect to playlist menu."
        )
      );
      this.router.navigate(['playlist']);
      return;
    }

    this.playlist = playlist;
    this.loadingMusic = true;
    this.playlistMusic = await this.apiHandler.fetchMusicPlaylistById(
      playlist.playlistID
    );
    this.loadingMusic = false;
  }

  protected playAllPlaylist() {
    this.playlistMusic.forEach(({ musicID }) => {
      this.eventBus.emit(
        new EventData(EventDataEnum.ADD_MUSIC_TO_QUEUE, musicID)
      );
    });
  }

  protected playOneMusic(musicId: number) {
    this.eventBus.emit(new EventData(EventDataEnum.CLEAR_MUSIC_QUEUE, null));
    this.eventBus.emit(
      new EventData(EventDataEnum.ADD_MUSIC_TO_QUEUE, musicId)
    );
  }

  protected firstLetter() {
    if (!this.playlist) {
      return '?';
    }
    return this.playlist.name.toUpperCase()[0];
  }
}
