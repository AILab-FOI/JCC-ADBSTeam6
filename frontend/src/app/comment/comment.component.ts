import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { CommentsDto } from 'src/types/api-dto/CommentsDto';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-comment',
  templateUrl: './comment.component.html',
  styleUrls: ['./comment.component.scss'],
})
export class CommentComponent implements OnInit {
  @Input('comment') comment?: CommentsDto;

  @Output('delete') deleteEvent = new EventEmitter();

  protected owner: UsersDto | null = null;
  protected music: MusicDto | null = null;

  constructor(
    private apiHandler: ApiHandlerService,
    private authService: AuthService,
    private eventBus: EventBusService
  ) {}

  async ngOnInit(): Promise<void> {
    if (!this.comment) return;
    this.owner = await this.apiHandler.fetchUserById(this.comment.Users_userID);
    this.music = await this.apiHandler.fetchMusicById(
      this.comment.Music_musicID
    );
  }

  deleteComment(): void {
    if (!this.authService.isLoggedIn() || !this.comment) return;

    this.apiHandler
      .deleteComment(
        this.comment.commentID,
        this.authService.getToken() as string
      )
      .then(() => {
        this.deleteEvent.emit();
      })
      .catch((err) => {
        this.eventBus.emit(new EventData(EventDataEnum.ERROR_POPUP, err));
      });
  }

  get isOwner(): boolean {
    if (!this.authService.isLoggedIn()) return false;

    const loggedUser = this.authService.getUser() as UsersDto;
    return loggedUser.userID === this.ownerId;
  }

  get ownerId(): number {
    if (!this.owner) {
      return -1;
    }

    return this.owner.userID;
  }

  get musicId(): number {
    if (!this.music) {
      return -1;
    }

    return this.music.musicID;
  }

  get ownerUsername(): String {
    if (!this.owner) {
      return 'OWNER ERROR';
    }

    return this.owner.username;
  }

  get musicTitle(): String {
    if (!this.music) {
      return 'MUSIC ERROR';
    }

    return this.music.title;
  }
}
