import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';

import { LibAModule } from '@ngc-example/lib-a';
import { DragulaModule } from 'ng2-dragula';

import { AppComponent } from './app.component';
import { DragulaComponent } from './dragula.component';

import {
  provideClient,
  ConnectModule,
  ElizaService,
} from '@ngc-example/connect';

@NgModule({
  declarations: [AppComponent, DragulaComponent],
  imports: [
    BrowserModule,
    FormsModule,
    LibAModule,
    DragulaModule,
    ConnectModule.forRoot({
      baseUrl: 'https://demo.connectrpc.com',
    }),
  ],
  bootstrap: [AppComponent],
  providers: [provideClient(ElizaService)],
})
export class AppModule {}
