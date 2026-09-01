import { Test, TestingModule } from '@nestjs/testing'
import { AuthService } from './auth.service'

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AuthService],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('getHello should be returned `Hello from Auth`', async () => {
    await new Promise((f) => setTimeout(f, 1000));
    expect(service.getHello()).toBe('Hello from Auth');
  }, 10000);
});
