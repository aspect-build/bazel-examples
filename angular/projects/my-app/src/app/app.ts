import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MyLib } from '@my-org/my-lib';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, MyLib],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  title = 'my-app';
}
