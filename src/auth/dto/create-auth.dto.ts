import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsString,
  MinLength,
} from 'class-validator';
import { RegisterRole } from '../interfaces/auth.interface';

export class CreateAuthDto {
  @IsString()
  @IsNotEmpty()
  username!: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  password!: string;

  @IsEmail()
  @IsNotEmpty()
  email!: string;

  @IsEnum(RegisterRole, {
    message: 'Role must be either SEEKER or RECRUITER',
  })
  @IsNotEmpty()
  role!: RegisterRole;
}
