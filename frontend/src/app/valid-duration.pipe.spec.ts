import { ValidDurationPipe } from './valid-duration.pipe';

describe('ValidDurationPipe', () => {
  it('create an instance', () => {
    const pipe = new ValidDurationPipe();
    expect(pipe).toBeTruthy();
  });

  it('Works fine', () => {
    const pipe = new ValidDurationPipe();

    expect(pipe.transform('00:05:02.838')).toEqual('5:02');
    expect(pipe.transform('05:20')).toEqual('5:20');
    expect(pipe.transform('05:01')).toEqual('5:01');
  });
});
