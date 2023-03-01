import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { LibAModule } from '@ngc-example/lib-a';
import { DragulaModule } from 'ng2-dragula';

import { AppComponent } from './app.component';
import { DragulaComponent } from './dragula.component';

@NgModule({
  declarations: [AppComponent, DragulaComponent],
  imports: [BrowserModule, LibAModule, DragulaModule],
  bootstrap: [AppComponent],
})
export class AppModule {}
