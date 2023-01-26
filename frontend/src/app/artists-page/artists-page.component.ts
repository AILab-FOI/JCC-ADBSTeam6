import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { ArtistsDto } from 'src/types/api-dto/ArtistsDto';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-artists-page',
  templateUrl: './artists-page.component.html',
  styleUrls: ['./artists-page.component.scss'],
})
export class ArtistsPageComponent implements OnInit {
  protected artistInfo: ArtistsDto | null = null;
  protected artistsMusics: MusicDto[] = [];
  protected loadingMusic: boolean = false;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private apiHandler: ApiHandlerService,
    private eventBus: EventBusService
  ) {}

  async ngOnInit(): Promise<void> {
    let artistIdStr: string | null = this.route.snapshot.paramMap.get('id');
    if (!artistIdStr) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          'Cannot properly read id specified in url. Redirect to home page.'
        )
      );
      this.router.navigate(['']);
      return;
    }

    const artistId = Number.parseInt(artistIdStr);
    this.artistInfo = await this.apiHandler.fetchArtistById(artistId);
    if (!this.artistInfo) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          "Queried artist doesn't exists. Redirect to home page."
        )
      );
      this.router.navigate(['']);
      return;
    }

    this.loadingMusic = true;
    this.artistsMusics = await this.apiHandler.fetchMusicOfArtist(
      this.artistInfo.artistID,
      -1,
      0
    );
    this.loadingMusic = false;
  }
}
