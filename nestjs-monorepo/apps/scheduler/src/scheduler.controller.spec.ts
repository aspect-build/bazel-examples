import { Test, TestingModule } from '@nestjs/testing';
import { SchedulerController } from './scheduler.controller';
import { SchedulerService } from './scheduler.service';

describe('SchedulerController', () => {
  let schedulerController: SchedulerController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [SchedulerController],
      providers: [SchedulerService],
    }).compile();

    schedulerController = app.get<SchedulerController>(SchedulerController);
  });

  describe('root', () => {
    it('should return "Hello World!"', () => {
      expect(schedulerController.getHello()).toBe('Hello World!');
    });
  });
});
