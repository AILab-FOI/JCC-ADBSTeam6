import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { PlaylistsDto } from 'src/types/api-dto/PlaylistsDto';
import { SearchResultDto } from 'src/types/api-dto/SearchResultDto';
import { SearchResultTypeEnum } from 'src/types/SearchResultType.enum';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-home-menu',
  templateUrl: './home-menu.component.html',
  styleUrls: ['./home-menu.component.scss'],
})
export class HomeMenuComponent implements OnInit {
  protected playlistList: PlaylistsDto[] = [];
  protected hitMusicList: MusicDto[] = [];

  protected SearchResultTypeEnum = SearchResultTypeEnum;
  protected resultSection: SearchResultTypeEnum = SearchResultTypeEnum.TITLE;
  protected loadingSearch: boolean = false;
  protected searchResult: SearchResultDto | null = null;

  protected musicsArtistsNames: string[] = [];

  constructor(
    private eventBus: EventBusService,
    private apiHandler: ApiHandlerService,
    private router: Router
  ) {}

  async ngOnInit(): Promise<void> {
    this.playlistList = await this.apiHandler.fetchAllPlaylist(-1, 0);
    this.playlistList = this.playlistList.filter((a) => a.name !== 'Likes');
    this.hitMusicList = await this.apiHandler.fetchHitMusic(-1, 0);

    this.musicsArtistsNames = this.hitMusicList.map((music) =>
      music.artists.map((a) => a.name).join(', ')
    );
  }

  playMusic(musicId: number): void {
    this.eventBus.emit(
      new EventData(EventDataEnum.ADD_MUSIC_TO_QUEUE, musicId)
    );
  }

  redirectToPlaylist(playlistId: number): void {
    this.router.navigate(['playlist', playlistId]);
  }

  redirectToArtist(artistId: number): void {
    this.router.navigate(['artists', artistId]);
  }

  redirectToMusic(musicId: number): void {
    this.router.navigate(['music', musicId]);
  }

  redirectToUser(userId: number): void {
    this.router.navigate(['user', userId]);
  }

  setResultSection(searchResultType: SearchResultTypeEnum) {
    this.resultSection = searchResultType;
  }

  async search(content: string): Promise<void> {
    this.searchResult = null;

    this.loadingSearch = true;
    this.searchResult = await this.apiHandler.searchByText(content, -1, 0);
    this.loadingSearch = false;
  }
}
