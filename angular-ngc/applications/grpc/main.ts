import { enableProdMode } from '@angular/core';
import { platformBrowser } from '@angular/platform-browser';

import { AppModule } from './app/app.module';

declare const process: any;
if (process.env.NODE_ENV === 'production') {
  enableProdMode();
}

platformBrowser()
  .bootstrapModule(AppModule)
  .catch((err) => console.error(err));
