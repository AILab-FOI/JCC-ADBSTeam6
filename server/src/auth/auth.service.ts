import { toUserDto } from '@/mapper/users.mapper';
import { CreateUserDto } from '@/users/dto/create-user.dto';
import { UsersDto } from '@/users/dto/user.dto';
import { UsersService } from '@/users/users.service';
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { compare } from 'bcrypt';
import { JwtPayload } from './dto/jwt-payload.type';
import { LoginInputDto } from './dto/login-input.dto';

@Injectable()
export class AuthService {
  constructor(
    private userService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(payload: JwtPayload): Promise<UsersDto | null> {
    const user = await this.userService.findOneEntityByEmail(payload.email);
    if (user) {
      return toUserDto(user);
    }

    return null;
  }

  async login(data: LoginInputDto) {
    const user = await this.userService.findOneEntityByEmail(data.email);
    if (!user || !this.comparePassword(data.password, user.password)) {
      throw new HttpException('Wrong credentials.', HttpStatus.UNAUTHORIZED);
    }

    const payload: JwtPayload = { email: user.email, sub: user.userid };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }

  async register(data: CreateUserDto): Promise<UsersDto> {
    return this.userService.create(data);
  }

  private async comparePassword(
    rawPassword: string,
    hashedPassord: string,
  ): Promise<boolean> {
    return await compare(rawPassword, hashedPassord);
  }
}
