import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';
import {
  provideClient,
  ConnectModule,
  ElizaService,
} from '@ngc-example/connect';

import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    FormsModule,
    ConnectModule.forRoot({
      baseUrl: 'https://demo.connectrpc.com',
    }),
  ],
  providers: [provideClient(ElizaService)],
  bootstrap: [AppComponent],
})
export class AppModule {}
