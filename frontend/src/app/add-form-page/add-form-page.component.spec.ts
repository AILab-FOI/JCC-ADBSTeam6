import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AddFormPageComponent } from './add-form-page.component';

describe('AddFormPageComponent', () => {
  let component: AddFormPageComponent;
  let fixture: ComponentFixture<AddFormPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ AddFormPageComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AddFormPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
