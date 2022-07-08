import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CommonModule } from '@ngc-example/common';
import { Component } from '@angular/core';
import { LibAComponent } from './lib-a.component';

@Component({
  selector: 'example-library-b',
  template: `
    <strong>
      The library component B! With
      <!-- <example-library></example-library> -->
    </strong>
  `,
})
class LibBComponent {}

describe('LibBComponent', () => {
  let component: LibBComponent;
  let fixture: ComponentFixture<LibBComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [LibAComponent, LibBComponent],
      imports: [CommonModule],
    }).compileComponents();

    fixture = TestBed.createComponent(LibBComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
