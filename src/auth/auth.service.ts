import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import AppError from '../common/errors/app.error';
import { EmailQueueService } from '../common/queues/email/email.queue';
import { ActivityLogService } from '../common/services/activity-log.service';
import { CustomLoggerService } from '../common/services/custom-logger.service';
import { PrismaService } from '../common/services/prisma.service';
import { RedisService } from '../common/services/redis.service';
import { AUTH_CONFIG } from './config/auth.config';
import { CreateAuthDto } from './dto/create-auth.dto';
import { UpdateAuthDto } from './dto/update-auth.dto';
import { AuthUtilsService } from './services/auth-utils.service';

/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */

@Injectable()
export class AuthService {
  constructor(
    private readonly authUtilsService: AuthUtilsService,
    private readonly prismaService: PrismaService,
    private readonly activityLogService: ActivityLogService,
    private readonly redisService: RedisService,
    private readonly emailQueueService: EmailQueueService,
    private readonly customLogger: CustomLoggerService,
  ) {}

  async create(
    payload: CreateAuthDto,
    meta: { ip: string; userAgent: string; device?: string },
  ) {
    const { email, password, username } = payload;
    const { ip, userAgent, device } = meta;

    this.customLogger.log(
      `Registration attempt for email: ${email}, username: ${username}`,
      'AuthService',
    );

    const { LOGIN_MAX_ATTEMPTS, LOGIN_WINDOW_MS } = AUTH_CONFIG.RATE_LIMIT;
    const { VERIFICATION } = AUTH_CONFIG.TOKEN_EXPIRY;

    // Check rate limiting for email, IP, and user agent
    await Promise.all([
      this.authUtilsService.checkRateLimit(
        `login:email:${email}`,
        LOGIN_MAX_ATTEMPTS,
        LOGIN_WINDOW_MS,
      ),
      this.authUtilsService.checkRateLimit(
        `login:ip:${ip}`,
        LOGIN_MAX_ATTEMPTS,
        LOGIN_WINDOW_MS,
      ),
    ]);

    // Validate password strength
    if (!this.authUtilsService.validatePassword(password)) {
      throw AppError.badRequest('Password does not meet security requirements');
    }

    // Check if user already exists with email or username
    const existingUser = await this.prismaService.authUser.findFirst({
      where: {
        OR: [{ email }, { username }],
      },
    });

    if (existingUser) {
      if (existingUser.email === email) {
        this.customLogger.warn(
          `Registration failed: Email already exists - ${email}`,
          'AuthService',
        );
        throw AppError.conflict('Email already exists!');
      }
      if (existingUser.username === username) {
        this.customLogger.warn(
          `Registration failed: Username already exists - ${username}`,
          'AuthService',
        );
        throw AppError.conflict('Username already exists!');
      }
    }

    // Generate verification code
    const verificationCode = this.authUtilsService.generateVerificationCode();
    const expiresAt = new Date(
      Date.now() + this.parseExpiryToSeconds(VERIFICATION) * 1000,
    );

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user with auth security in a transaction
    const newUser = await this.prismaService.$transaction(
      async (tx): Promise<{ id: string; email: string; username: string }> => {
        // Create auth user
        const user = await tx.authUser.create({
          data: {
            email,
            username,
            password: hashedPassword,
            role: 'USER',
            verified: false,
            status: 'ACTIVE',
            provider: 'local',
          },
        });

        // Create auth security record
        await tx.authSecurity.create({
          data: {
            authId: user.id,
            failedAttempts: 0,
            mfaEnabled: false,
            lastPasswordChange: new Date(),
          },
        });

        // Create email history record for verification email
        await tx.emailHistory.create({
          data: {
            authId: user.id,
            emailTo: email,
            emailType: 'verification',
            subject: 'Verify your email address',
            messageId: `verify-${user.id}-${Date.now()}`,
            emailStatus: 'pending',
            ipAddress: ip,
            userAgent: userAgent,
          },
        });

        // Log user registration activity
        await this.activityLogService.logCreate(
          'authUser',
          user.id,
          {
            email,
            username,
            role: 'USER',
            status: 'ACTIVE',
            verified: 'false',
            provider: 'local',
          },
          { ip, userAgent, actionedBy: user.id, device },
          tx,
        );

        return user;
      },
    );
  }

  findAll() {
    return `This action returns all auth`;
  }

  findOne(id: number) {
    return `This action returns a #${id} auth`;
  }

  update(id: number, updateAuthDto: UpdateAuthDto) {
    return `This action updates a #${id} auth`;
  }

  remove(id: number) {
    return `This action removes a #${id} auth`;
  }
}
