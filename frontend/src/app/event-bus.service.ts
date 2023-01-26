import { Injectable } from '@angular/core';
import { filter, map, Subject, Subscription } from 'rxjs';
import { EventData, EventDataEnum } from './event-data';

@Injectable({
  providedIn: 'root',
})
/**
 * source: https://levelup.gitconnected.com/communicate-between-angular-components-using-rxjs-7221e0468b2
 */
export class EventBusService {
  private subject: Subject<EventData> = new Subject();

  constructor() {}

  public emit(event: EventData) {
    this.subject.next(event);
  }

  public on(name: EventDataEnum, action: any): Subscription {
    return this.subject
      .pipe(
        filter((e) => e.getName() === name),
        map((e: EventData) => e.getValue())
      )
      .subscribe(action);
  }
}
