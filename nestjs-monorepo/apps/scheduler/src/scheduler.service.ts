import { Injectable } from '@nestjs/common';

@Injectable()
export class SchedulerService {
  getHello(): string {
    return 'Hello World!';
  }
}
