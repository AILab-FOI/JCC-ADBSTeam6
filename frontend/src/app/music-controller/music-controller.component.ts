import { Component, EventEmitter, Input, Output } from '@angular/core';

@Component({
  selector: 'app-music-controller',
  templateUrl: './music-controller.component.html',
  styleUrls: ['./music-controller.component.scss'],
})
export class MusicControllerComponent {
  @Input('musicPaused') musicPaused!: boolean;
  @Input('duration') duration?: number; // In s
  @Input('currentTime') currentTime!: number; // In s
  @Input() time: number = 0;

  @Output('pauseMusic') pauseMusic = new EventEmitter();
  @Output('playMusic') playMusic = new EventEmitter();
  @Output('change-time') changeTimeEvent = new EventEmitter();
  @Output('next-music') nextMusicEvent = new EventEmitter();
  @Output('prev-music') prevMusicEvent = new EventEmitter();

  get progression(): number {
    if (!this.duration || this.duration <= 0) return 0;

    return Math.min((this.currentTime / this.duration) * 100, 100);
  }

  changeMusicState() {
    if (this.musicPaused) {
      this.playMusic.emit();
    } else {
      this.pauseMusic.emit();
    }
  }

  changeProgression(newProgression: number): void {
    this.changeTimeEvent.emit((newProgression * (this.duration || 0)) / 100);
  }
}
