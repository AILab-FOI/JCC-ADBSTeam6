import { NoAutoPlaylistPipe } from './no-auto-playlist.pipe';

describe('NoAutoPlaylistPipe', () => {
  it('create an instance', () => {
    const pipe = new NoAutoPlaylistPipe();
    expect(pipe).toBeTruthy();
  });
});
