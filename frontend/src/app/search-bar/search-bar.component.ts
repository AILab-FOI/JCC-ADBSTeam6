import { Component, EventEmitter, Input, Output } from '@angular/core';

@Component({
  selector: 'app-search-bar',
  templateUrl: './search-bar.component.html',
  styleUrls: ['./search-bar.component.scss'],
})
export class SearchBarComponent {
  data = '';

  @Input('placeholder') placeholder = '';
  @Input('isloading') isLoading = false;

  @Output('query') queryEvent = new EventEmitter();

  query() {
    this.queryEvent.emit(this.data);
  }
}
