import { IsString, IsEmail, MinLength } from "class-validator";

export class CreateUserDto {
  @IsString()
  @MinLength(8)
  password!: string;

  @IsEmail()
  email!: string;
}
