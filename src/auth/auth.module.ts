import { Module } from '@nestjs/common';
import { ActivityLogService } from '../common/services/activity-log.service';
import { EmailService } from '../common/services/email.service';
import { PrismaService } from '../common/services/prisma.service';
import { RedisService } from '../common/services/redis.service';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuthUtilsService } from './services/auth-utils.service';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    AuthUtilsService,
    PrismaService,
    ActivityLogService,
    EmailService,
    RedisService,
  ],
})
export class AuthModule {}
