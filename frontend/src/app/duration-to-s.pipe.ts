import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'durationToS',
})
export class DurationToSPipe implements PipeTransform {
  transform(value?: string | String, ...args: unknown[]): number | undefined {
    if (!value) return undefined;

    let splitted = value.split(':');
    let [min, sec] = [splitted.at(-2), splitted.at(-1)];
    if (!min) min = '0';
    if (!sec) sec = '0';

    return Number.parseInt(min) * 60 + Number.parseInt(sec);
  }
}
