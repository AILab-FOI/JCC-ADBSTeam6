import { Component, EventEmitter, Input, Output } from '@angular/core';

export type PopupType = 'error' | 'info';

@Component({
  selector: 'app-popup',
  templateUrl: './popup.component.html',
  styleUrls: ['./popup.component.scss'],
})
export class PopupComponent {
  @Input('message') message: string = '';
  @Input('type') type!: PopupType;
  @Output() clearPopup = new EventEmitter();

  constructor() {
    const timer = setTimeout(() => {
      this.clearPopup.emit();
      clearTimeout(timer);
    }, 3 * 1000);
  }
}
