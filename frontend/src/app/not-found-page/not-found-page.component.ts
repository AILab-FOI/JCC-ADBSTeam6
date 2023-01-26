import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-not-found-page',
  templateUrl: './not-found-page.component.html',
  styleUrls: ['./not-found-page.component.scss'],
})
export class NotFoundPageComponent implements OnInit {
  constructor(private router: Router, private eventBus: EventBusService) {}

  ngOnInit(): void {
    this.eventBus.emit(
      new EventData(
        EventDataEnum.ERROR_POPUP,
        `The url you tried to entered was not valid. Redirected to home page.`
      )
    );
    this.router.navigate(['']);
  }
}
