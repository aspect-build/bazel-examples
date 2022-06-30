import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CommonModule } from '@ngc-example/common';

import { LibAComponent } from './lib-a.component';

describe('LibAComponent', () => {
  let component: LibAComponent;
  let fixture: ComponentFixture<LibAComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [LibAComponent],
      imports: [CommonModule],
    }).compileComponents();

    fixture = TestBed.createComponent(LibAComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
