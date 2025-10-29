import { AuthModule } from '@app/auth'
import { Module } from '@nestjs/common'
import { ApiController } from './api.controller'
import { ApiService } from './api.service'

@Module({
  imports: [AuthModule],
  controllers: [ApiController],
  providers: [ApiService],
})
export class ApiModule {}
