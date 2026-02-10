import { AuthService } from '@app/auth/auth.service'
import { Controller, Get } from '@nestjs/common'
import { SchedulerService } from './scheduler.service'

@Controller()
export class SchedulerController {
  constructor(
    private readonly schedulerService: SchedulerService,
    private readonly authService: AuthService,
  ) {}

  @Get()
  getHello(): string {
    return this.schedulerService.getHello();
  }

  @Get('auth')
  getAuth(): string {
    return this.authService.getHello();
  }
}
