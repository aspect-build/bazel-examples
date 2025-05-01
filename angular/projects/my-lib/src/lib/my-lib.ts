import { Component } from '@angular/core';

@Component({
  selector: 'lib-my-lib',
  standalone: true,
  imports: [],
  template: ` <p>my-lib works!</p> `,
  styles: [
    `
      :host {
        display: block;
        margin-top: 1rem;
      }
    `,
  ],
})
export class MyLib {}
