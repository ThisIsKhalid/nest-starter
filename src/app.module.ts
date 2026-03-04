import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { WinstonModule } from 'nest-winston';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { winstonConfig } from './common/config/winston.config';
import { CustomLoggerModule } from './common/modules/custome-logger.module';
import { RateLimitModule } from './common/modules/rate-limit.module';
import { RedisModule } from './common/modules/redis.module';

@Module({
  imports: [
    // Load environment variables globally
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    // Winston logger module (global - can be injected anywhere)
    WinstonModule.forRoot(winstonConfig),
    // Custom logger module (global - can be injected anywhere)
    CustomLoggerModule,
    // Redis module (global - can be injected anywhere)
    RedisModule,
    // Rate limiting module (global - throttles requests using Redis)
    RateLimitModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
