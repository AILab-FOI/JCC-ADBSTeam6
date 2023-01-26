export class EventData {
  constructor(private name: EventDataEnum, private value: any) {}

  public getName(): EventDataEnum {
    return this.name;
  }

  public getValue(): any {
    return this.value;
  }
}

export enum EventDataEnum {
  ADD_MUSIC_TO_QUEUE,
  CLEAR_MUSIC_QUEUE,
  ERROR_POPUP,
  INFO_POPUP,
}
