import {
  AfterViewInit,
  Component,
  ElementRef,
  OnDestroy,
  OnInit,
  ViewChild,
} from '@angular/core';
import { Subscription } from 'rxjs';
import { MusicDto } from 'src/types/api-dto/MusicDto';
import { ApiHandlerService } from './api-services/api-handler.service';
import { EventBusService } from './event-bus.service';
import { EventDataEnum } from './event-data';
import { PopupType } from './popup/popup.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit, OnDestroy {
  title = 'frontend';
  protected musicPlaying = false;
  protected musicPaused = true;
  protected showNavMenu = false;

  protected volumeMuted = false;
  protected volumeLevel = 66;

  protected currentMusicInfo?: MusicDto | null;
  private currentMusicIdx: number = -1; // idx of musicIdQueue
  private musicIdQueue: number[] = [];

  protected popupQueue: { message: string; type: PopupType }[] = [];

  private audioCtx: AudioContext = new window.AudioContext();
  private audioGain = this.audioCtx.createGain();
  private currentBlock: number = 0;
  private offsetMoveTime: number = 0;

  private maxBlockToLoad: number = 10 * 10 * 4;
  private eventBusListener: Subscription[] = [];
  private pauseDelay: number = 0;
  private startMusicDate: Date | null = null;
  private startBufferDate: Date | null = null;
  private startPauseDate: Date | null = null;
  private lastAudioSource: AudioBufferSourceNode | null = null;

  protected totalDuration = 0;
  private totalDurationInterval: NodeJS.Timer | null = null;

  private audioSourceBuffer: (AudioBufferSourceNode | null)[] = [
    null,
    null,
    null,
    null,
  ];

  constructor(
    private eventBus: EventBusService,
    private apiHandlerService: ApiHandlerService
  ) {}

  ngOnDestroy(): void {
    this.audioSourceBuffer.forEach((a) => {
      if (a) a.removeEventListener('ended', this.endedEventListener.bind(this));
    });

    this.eventBusListener.forEach((a) => a.unsubscribe());
    if (this.totalDurationInterval) clearInterval(this.totalDurationInterval);
  }

  ngOnInit(): void {
    this.audioGain.connect(this.audioCtx.destination);
    this.eventBusListener.push(
      this.eventBus.on(
        EventDataEnum.ADD_MUSIC_TO_QUEUE,
        async (musicId: number) => {
          this.musicIdQueue.push(musicId);
          if (this.musicIdQueue.length === 1) {
            await this.loadNextMusic();
            this.musicPlaying = true;
          }
        }
      )
    );

    this.eventBusListener.push(
      this.eventBus.on(EventDataEnum.ERROR_POPUP, (message: string) => {
        this.popupQueue.push({ message, type: 'error' });
      })
    );

    this.eventBusListener.push(
      this.eventBus.on(EventDataEnum.INFO_POPUP, (message: string) => {
        this.popupQueue.push({ message, type: 'info' });
      })
    );

    this.eventBusListener.push(
      this.eventBus.on(EventDataEnum.CLEAR_MUSIC_QUEUE, () => {
        this.musicIdQueue = [];
        this.currentMusicIdx = -1;
        this.musicPlaying = false;

        this.resetSources();
      })
    );
  }

  endedEventListener(): void {
    if (!this.musicPaused && this.musicPlaying) {
      this.playNextBlock();
    }
  }

  removeErrorMessage(messageIndex: number) {
    if (messageIndex >= this.popupQueue.length) return;

    this.popupQueue.splice(messageIndex, 1);
  }

  async loadNextMusic() {
    this.startMusicDate = null;
    this.startPauseDate = null;
    this.currentMusicIdx++;
    this.audioSourceBuffer = this.audioSourceBuffer.map((_) => null);

    const nextMusicId = this.musicIdQueue[this.currentMusicIdx];
    console.log(nextMusicId);
    console.log({ ids: this.musicIdQueue });
    console.log({ idx: this.currentMusicIdx });

    this.currentMusicInfo = await this.apiHandlerService.fetchMusicById(
      nextMusicId
    );
    console.log(this.currentMusicInfo);

    this.currentBlock = 0;
    if (!this.totalDurationInterval) {
      this.totalDurationInterval = setInterval(
        this.computeTotalDuration.bind(this),
        50
      );
    }
    this.apiHandlerService.increaseViewsCounter(nextMusicId);

    let flag = true;
    while (flag) {
      flag = await this.loadFirstEmptySlotOfAudioBuffer(this.maxBlockToLoad);
      console.log(flag);
    }

    console.log('play');
    this.playNextBlock();
  }

  updateTime(second: number) {
    if (!this.startMusicDate || this.totalDuration < 1) return;

    const blockPerSecond =
      (this.currentBlock -
        this.audioSourceBuffer.filter((a) => a !== null).length *
          this.maxBlockToLoad) /
      this.totalDuration;

    const currentBlock = blockPerSecond * second;

    this.offsetMoveTime += (second - this.totalDuration) * 1000;
    if (
      currentBlock >= this.currentBlock &&
      currentBlock <=
        this.currentBlock +
          this.audioSourceBuffer.filter((a) => a !== null).length *
            this.maxBlockToLoad
    ) {
      const itenb = Math.floor(
        (this.currentBlock +
          this.audioSourceBuffer.filter((a) => a !== null).length *
            this.maxBlockToLoad -
          currentBlock) /
          this.maxBlockToLoad
      );

      for (let i = 0; i < itenb; i++) {
        this.rotateAudioBuffer();
      }

      this.loadFirstEmptySlotOfAudioBuffer(this.maxBlockToLoad).then(() => {
        this.lastAudioSource?.stop();
      });
    } else {
      this.audioSourceBuffer.fill(null);

      this.loadFirstEmptySlotOfAudioBuffer(this.maxBlockToLoad).then(() => {
        this.lastAudioSource?.stop();
        // this.playNextBlock();
      });
    }
  }

  private async loadFirstEmptySlotOfAudioBuffer(
    Nblocks: number
  ): Promise<boolean> {
    const idx = this.audioSourceBuffer.indexOf(null);

    if (idx < 0) return false;

    const lastAudioSource = this.audioSourceBuffer[idx];
    if (lastAudioSource) {
      lastAudioSource.removeEventListener(
        'ended',
        this.endedEventListener.bind(this)
      );
    }

    const buffer = await this.apiHandlerService.fetchMusicBufferBlock(
      this.musicIdQueue[this.currentMusicIdx],
      this.currentBlock,
      Nblocks
    );
    console.log(buffer);

    this.currentBlock += Nblocks;

    const audioData = await this.audioCtx.decodeAudioData(
      buffer,
      (_) => {},
      (err) => {
        if (err) console.error(err);
      }
    );
    const audioSource = this.audioCtx.createBufferSource();

    audioSource.addEventListener('ended', this.endedEventListener.bind(this));

    audioSource.buffer = audioData;

    audioSource.connect(this.audioCtx.destination);
    audioSource.connect(this.audioGain);
    this.audioSourceBuffer[idx] = audioSource;
    return true;
  }

  private rotateAudioBuffer() {
    if (this.audioSourceBuffer[0] === null) return;

    for (let i = 0; i < this.audioSourceBuffer.length - 1; i++) {
      this.audioSourceBuffer[i] = this.audioSourceBuffer[i + 1];
    }

    this.audioSourceBuffer[this.audioSourceBuffer.length - 1] = null;
  }

  private async playNextBlock() {
    this.musicPlaying = true;
    const audioSource = this.audioSourceBuffer[0];

    if (!audioSource) {
      if (this.musicIdQueue.length - 1 >= this.currentMusicIdx) {
        this.loadNextMusic();
      } else this.musicPlaying = false;
      return;
    }
    this.rotateAudioBuffer();

    this.lastAudioSource = audioSource;
    audioSource.start(0);
    this.musicPaused = false;
    this.startBufferDate = new Date();
    if (!this.startMusicDate) this.startMusicDate = new Date();

    this.loadFirstEmptySlotOfAudioBuffer(this.maxBlockToLoad);
  }

  private computeTotalDuration(): void {
    if (!this.startMusicDate) {
      this.totalDuration = 0;
      return;
    }

    let currPauseTime = 0;
    if (this.startPauseDate)
      currPauseTime = Math.abs(
        this.startPauseDate?.getTime() - new Date().getTime()
      );

    const timedelta = Math.abs(
      new Date().getTime() -
        this.startMusicDate.getTime() -
        this.pauseDelay -
        currPauseTime +
        this.offsetMoveTime
    );

    this.totalDuration = timedelta / 1000;
  }

  private restartAudio(
    oldSourceNode: AudioBufferSourceNode,
    delay: number
  ): void {
    oldSourceNode.removeEventListener(
      'ended',
      this.endedEventListener.bind(this)
    );

    const audioSource = this.audioCtx.createBufferSource();
    audioSource.buffer = oldSourceNode.buffer;
    audioSource.connect(this.audioCtx.destination);
    audioSource.connect(this.audioGain);
    audioSource.addEventListener('ended', this.endedEventListener.bind(this));

    audioSource.start(0, delay - 0.2);
  }

  playMusic() {
    let playDelay = 0;
    if (this.startPauseDate) {
      const pauseTime = Math.abs(
        (this.startPauseDate?.getTime() || 0) - new Date().getTime()
      );
      if (this.startBufferDate) {
        playDelay =
          Math.abs(
            this.startBufferDate.getTime() - new Date().getTime() - pauseTime
          ) / 1000;
      }
      this.pauseDelay += pauseTime;
    }

    this.startPauseDate = null;
    if (this.lastAudioSource)
      this.restartAudio(this.lastAudioSource, playDelay);
    this.musicPaused = false;
  }

  pauseMusic() {
    if (this.lastAudioSource) {
      this.startPauseDate = new Date();
      this.lastAudioSource.stop();
    }

    this.musicPaused = true;
  }

  switchShowNavMenuState() {
    this.showNavMenu = !this.showNavMenu;
  }

  get volume(): number {
    return -1 + (3 * this.volumeLevel) / 100;
  }

  switchVolumeMutedState() {
    this.volumeMuted = !this.volumeMuted;
    this.audioGain.gain.value = this.volumeMuted ? -1 : this.volume;
  }

  updateVolume(value: number) {
    this.volumeLevel = value;
    this.audioGain.gain.value = this.volume;
  }

  resetSources() {
    this.musicPlaying = false;
    this.audioSourceBuffer.forEach((source) => {
      source?.removeEventListener('ended', this.endedEventListener.bind(this));
    });
    this.lastAudioSource?.removeEventListener(
      'ended',
      this.endedEventListener.bind(this),
      {}
    );
    this.lastAudioSource?.stop();
    this.audioSourceBuffer = [null, null, null, null];
  }

  nextMusic() {
    console.log('next');
    this.resetSources();
    this.currentMusicIdx = Math.max(
      this.currentMusicIdx,
      this.musicIdQueue.length - 2
    );

    console.log(this.currentMusicIdx);
    console.log(this.musicIdQueue);

    this.loadNextMusic();
  }

  prevMusic() {
    this.resetSources();
    this.currentMusicIdx = Math.min(this.currentMusicIdx - 2, -1);

    this.loadNextMusic();
  }
}
