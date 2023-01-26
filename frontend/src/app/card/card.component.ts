import { Component, EventEmitter, Input, Output } from '@angular/core';

@Component({
  selector: 'app-card',
  templateUrl: './card.component.html',
  styleUrls: ['./card.component.scss'],
})
export class CardComponent {
  @Input('imgColor') imgColor: string = 'bg-blue-600';
  @Input('name') name!: String;
  @Input('description') description?: String | null;
  @Input('playable') playable?: boolean;
  @Input('icon-letter') iconLetter?: string;

  @Output('play') playEvent = new EventEmitter<null>();
}
