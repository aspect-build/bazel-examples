import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { FormsModule } from '@angular/forms';
import {
  provideClient,
  ConnectModule,
  ElizaService,
} from '@ngc-example/connect';

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AppComponent],
      providers: [provideClient(ElizaService)],
      imports: [
        FormsModule,
        ConnectModule.forRoot({
          baseUrl: 'https://demo.connectrpc.com',
        }),
      ],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it(`should have as title 'Eliza'`, () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app.title).toEqual('Eliza');
  });

  it('should render title', () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('h1')?.textContent).toContain('Eliza');
  });

  it('should correctly inject the ElizaService', () => {
    const service = TestBed.get(ElizaService);
    expect(service.say).toBeDefined();
    // TODO: why isn't this defined like the examples-es repo?
    // See: https://github.com/connectrpc/examples-es/blob/855520e9312ab0acf9d72040f3013018ef89c8c9/angular/src/app/app.component.spec.ts#L41-L45
    // expect(service.introduce).toBeDefined();
  });
});
