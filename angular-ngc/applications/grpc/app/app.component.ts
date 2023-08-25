import { Component, Inject } from '@angular/core';
import { ObservableClient, ElizaService } from '@ngc-example/connect';

interface Response {
  text: string;
  sender: 'eliza' | 'user';
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = 'Eliza';
  project = 'Angular';
  statement: string = '';
  responses: Response[] = [
    {
      text: 'What is your name?',
      sender: 'eliza',
    },
  ];
  introFinished: boolean = false;

  constructor(
    @Inject(ElizaService)
    private client: ObservableClient<typeof ElizaService>
  ) {}

  onSend(event?: MouseEvent) {
    if (event) {
      event.stopPropagation();
    }
    this.responses = [
      ...this.responses,
      { text: this.statement, sender: 'user' },
    ];
    if (this.introFinished) {
      this.client.say({ sentence: this.statement }).subscribe((next) => {
        this.responses = [
          ...this.responses,
          { text: next.sentence, sender: 'eliza' },
        ];
      });
    } else {
      this.client.introduce({ name: this.statement }).subscribe(
        (next) => {
          this.responses = [
            ...this.responses,
            { text: next.sentence, sender: 'eliza' },
          ];
        },
        (err) => console.log(err),
        () => {
          this.introFinished = true;
        }
      );
    }
    this.statement = '';
  }
}
