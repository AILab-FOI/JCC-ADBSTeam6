import { Test, TestingModule } from '@nestjs/testing';
import { PlaylistMusicsService } from './playlist-musics.service';

describe('PlaylistMusicsService', () => {
  let service: PlaylistMusicsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PlaylistMusicsService],
    }).compile();

    service = module.get<PlaylistMusicsService>(PlaylistMusicsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
