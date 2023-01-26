import { TestBed } from '@angular/core/testing';

import { MockAuthService } from './mock-auth.service';

describe('AuthServiceService', () => {
  let service: MockAuthService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(MockAuthService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
