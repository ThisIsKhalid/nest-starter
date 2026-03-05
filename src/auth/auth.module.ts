import { Module } from '@nestjs/common';
import { QueueModule } from '../common/modules/queue.module';
import { ActivityLogService } from '../common/services/activity-log.service';
import { PrismaService } from '../common/services/prisma.service';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuthUtilsService } from './services/auth-utils.service';

@Module({
  imports: [QueueModule],
  controllers: [AuthController],
  providers: [
    AuthService,
    AuthUtilsService,
    PrismaService,
    ActivityLogService,
  ],
  exports: [AuthUtilsService],
})
export class AuthModule {}

