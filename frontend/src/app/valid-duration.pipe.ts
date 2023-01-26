import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'validDuration',
})
export class ValidDurationPipe implements PipeTransform {
  transform(value: string | number, ...args: unknown[]): string | undefined {
    if (!value) return undefined;

    let secNum = 0;
    let minNum = 0;

    if (typeof value === 'number') {
      secNum = Math.round(value % 60);
      minNum = Math.floor(value / 60);
    } else if (typeof value === 'string') {
      let splitted = value.split(':');
      let [min, sec] = [splitted.at(-2), splitted.at(-1)];

      secNum = Number.parseInt(sec || '00');
      minNum = Number.parseInt(min || '00');
    } else
      throw new Error(
        "Wrong type: expected 'number' or 'string', got " + typeof value
      );

    return `${minNum}:${
      secNum < 10 ? '0' + secNum.toString() : secNum.toString()
    }`;
  }
}
