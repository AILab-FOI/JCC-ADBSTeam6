import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { MusicCreateDto } from 'src/types/api-dto/MusicCreateDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';
import { OptionType } from '../multiple-select/multiple-select.component';

@Component({
  selector: 'app-add-form-page',
  templateUrl: './add-form-page.component.html',
  styleUrls: ['./add-form-page.component.scss'],
})
export class AddFormPageComponent implements OnInit {
  protected title = '';
  protected description = '';
  protected turnOffComment = false;
  protected musicFile?: File;
  protected artistIds: number[] = [];
  protected genreIds: number[] = [];

  protected errorMessage = '';

  protected loadingSubmit = false;

  protected artistOptions: OptionType[] = [];
  protected genreOptions: OptionType[] = [];

  constructor(
    private apiHandler: ApiHandlerService,
    private authService: AuthService,
    private router: Router,
    private eventBus: EventBusService
  ) {}

  async ngOnInit() {
    if (!this.authService.isLoggedIn()) {
      this.eventBus.emit(
        new EventData(
          EventDataEnum.ERROR_POPUP,
          "Can't access this page. Please login before."
        )
      );
      this.router.navigate(['auth']);
      return;
    }

    this.artistOptions = (await this.apiHandler.fetchAllArtists(-1, 0)).map(
      (a) => ({
        value: a.artistID,
        display: a.name,
      })
    );

    this.genreOptions = (await this.apiHandler.fetchAllGenres(-1, 0)).map(
      (a) => ({
        value: a.tagID,
        display: a.name,
      })
    );
  }

  setArtistIds(values: OptionType[]) {
    this.artistIds = values.map((a) => a.value);
  }

  setGenreIds(values: OptionType[]) {
    this.genreIds = values.map((a) => a.value);
  }

  getDurationFromFile(): number {
    if (!this.musicFile) {
      return 0;
    }

    return 0;
  }

  changeFile(event: Event) {
    const input = event.target as HTMLInputElement;

    if (!input.files?.length) {
      return;
    }

    this.musicFile = input.files[0];
  }

  async submit() {
    this.loadingSubmit = true;
    if (!this.authService.isLoggedIn()) return;
    if (!this.musicFile) {
      this.errorMessage = 'You need to specify the audio file.';
      return;
    }

    const data: MusicCreateDto = {
      title: this.title,
      description: this.description,
      artistIds: this.artistIds,
      genreIds: this.genreIds,
      turnOffComments: this.turnOffComment,
    };

    if (!data.title) {
      this.errorMessage = 'Please specify a title.';
      return;
    }

    if (!data.description) {
      this.errorMessage = 'Please specify a description.';
      return;
    }

    if (data.artistIds.length === 0) {
      this.errorMessage = 'You need to choose at least one artist.';
      return;
    }

    if (data.genreIds.length === 0) {
      this.errorMessage = 'You need to choose at lease one genre.';
      return;
    }

    this.apiHandler
      .submitMusic(data, this.musicFile, this.authService.getToken() as string)
      .then(() => {
        this.eventBus.emit(
          new EventData(
            EventDataEnum.INFO_POPUP,
            'Succefully added music ' + data.title + '.'
          )
        );
        this.loadingSubmit = false;
      })
      .catch((err) => {
        this.errorMessage = err;
      });
  }
}
