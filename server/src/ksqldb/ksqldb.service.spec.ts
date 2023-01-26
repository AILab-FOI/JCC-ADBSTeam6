import { Test, TestingModule } from '@nestjs/testing';
import { KsqldbService } from './ksqldb.service';

describe('KsqldbService', () => {
  let service: KsqldbService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [KsqldbService],
    }).compile();

    service = module.get<KsqldbService>(KsqldbService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
