import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MusicControllerComponent } from './music-controller.component';

describe('MusicControllerComponent', () => {
  let component: MusicControllerComponent;
  let fixture: ComponentFixture<MusicControllerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ MusicControllerComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MusicControllerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
