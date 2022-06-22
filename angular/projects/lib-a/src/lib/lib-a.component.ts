import { Component } from '@angular/core';

@Component({
  selector: 'example-library',
  template: `
    <strong>
      The library component! With <lib-common></lib-common>
    </strong>
  `,
  styles: [':host { display: block; }']
})
export class LibAComponent {
}
