import { Component } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { CommonModule } from '@ngc-example/common';
import { LibAComponent } from './lib-a.component';

@Component({
  selector: 'example-pkg-b',
  template: `
    <strong>
      The library component B! With
      <span *ngIf="showSpan">SPAN!</span>
      <example-pkg></example-pkg>
    </strong>
  `,
})
class LibBComponent {
  showSpan = true;
}

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
    const spans = fixture.debugElement.queryAll(By.css('SPAN'));
    expect(spans.length).withContext('Should have rendered 1 span').toEqual(1);
    if (spans.length) {
      expect(spans[0].nativeElement.textContent)
        .withContext('should have the correct contents in the span')
        .toEqual('SPAN!');
    }
  });

  it('should create the <example-pkg>', () => {
    const exampleComp = fixture.debugElement.queryAll(By.css('example-pkg'));
    expect(exampleComp.length).toBe(1);
  });
});
