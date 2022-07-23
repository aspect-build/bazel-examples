import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { LibAModule } from 'lib-a';

import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, LibAModule],
  bootstrap: [AppComponent],
})
export class AppModule {}
