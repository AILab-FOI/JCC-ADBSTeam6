import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PlaylistMenuComponent } from './playlist-menu.component';

describe('PLaylistMenuComponent', () => {
  let component: PlaylistMenuComponent;
  let fixture: ComponentFixture<PlaylistMenuComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ PlaylistMenuComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PlaylistMenuComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
