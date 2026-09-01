import { AuthModule } from '@app/auth/auth.module'
import { Module } from '@nestjs/common'
import { SchedulerController } from './scheduler.controller'
import { SchedulerService } from './scheduler.service'

@Module({
  imports: [AuthModule],
  controllers: [SchedulerController],
  providers: [SchedulerService],
})
export class SchedulerModule {}
