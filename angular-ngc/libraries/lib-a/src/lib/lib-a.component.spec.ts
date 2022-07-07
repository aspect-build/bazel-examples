import 'zone.js/dist/zone-testing-bundle';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CommonModule } from '@ngc-example/common';

import { LibAComponent } from './lib-a.component';

import { getTestBed } from '@angular/core/testing';
import {
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting,
} from '@angular/platform-browser-dynamic/testing';

// declare const require: any;

// First, initialize the Angular testing environment.
getTestBed().initTestEnvironment(
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting()
);
// // Then we find all the tests.
// const context = require.context('./', true, /\.spec\.ts$/);
// // And load the modules.
// context.keys().map(context);

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
