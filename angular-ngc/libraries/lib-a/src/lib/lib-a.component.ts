import { Component } from '@angular/core';

import { TITLE } from './strings';

@Component({
  selector: 'example-library',
  template: `
    <strong>
      The ${TITLE} library component! With <lib-common></lib-common>
    </strong>
  `,
  styleUrls: ['./lib-a.component.css'],
})
export class LibAComponent {}
