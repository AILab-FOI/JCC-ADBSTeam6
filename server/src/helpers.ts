export function extractLimitOffset(o: { [key: string]: string }): {
  limit: number;
  offset: number;
} {
  return {
    limit: Number.parseInt(o?.limit || '-1'),
    offset: Number.parseInt(o?.offset || '0'),
  };
}

/**
 * source: https://stackoverflow.com/questions/8609289/convert-a-binary-nodejs-buffer-to-javascript-arraybuffer
 */
export function toArrayBuffer(buf: Buffer): ArrayBuffer {
  const ab = new ArrayBuffer(buf.length);
  const view = new Uint8Array(ab);
  for (let i = 0; i < buf.length; ++i) {
    view[i] = buf[i];
  }
  return ab;
}

export function randomString(length: number): string {
  const chars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ7894561230';

  let s = '';
  for (let _ = 0; _ < length; _++) {
    s += randomChoice(chars);
  }

  return s;
}

export function addZero(n: number): string {
  if (n < 10) return '0' + n;
  else return n.toString();
}

export function randomChoice(iterable: string): string;
export function randomChoice<T>(iterable: Array<T>): T;
export function randomChoice<T>(iterable: Array<T> | string): T | string {
  const len = iterable.length;
  const idx = Math.floor(Math.random() * len);

  return iterable[idx];
}

export function setSkipAndTake({
  limit,
  offset,
}: {
  limit: number;
  offset: number;
}): { skip: number; take: number } {
  let o: any = {};
  if (limit >= 1) {
    o = {
      skip: offset,
      take: limit,
    };
  }

  return o;
}
