import { Injectable } from '@angular/core';
import { UsersDto } from 'src/types/api-dto/UsersDto';
import { ApiHandlerService } from '../api-services/api-handler.service';
import { IAuthService } from './i-auth.service';

@Injectable({
  providedIn: 'root',
})
export class AuthService implements IAuthService {
  private user: UsersDto | null = null;
  private isLoggedInPriv: boolean = false;
  private token: string | null = null;

  constructor(private apiHandler: ApiHandlerService) {}

  async disconnect(): Promise<void> {
    this.isLoggedInPriv = false;
    this.user = null;
  }

  async register({
    lastName,
    firstName,
    email,
    password,
    username,
  }: {
    lastName: string;
    firstName: string;
    email: string;
    password: string;
    username: string;
  }): Promise<UsersDto> {
    return new Promise(async (r, errf) => {
      this.apiHandler
        .register({ lastName, firstName, email, password, username })
        .then((user) => {
          if (user.username !== username) {
            return errf('Error while trying to register user.');
          }

          return r(user);
        })
        .catch((err) => {
          errf(err.message);
        });
    });
  }

  isLoggedIn(): boolean {
    return this.isLoggedInPriv;
  }

  getUser(): UsersDto | null {
    return this.user;
  }

  getToken(): string | null {
    return this.token;
  }

  async login({
    email,
    password,
  }: {
    email: string;
    password: string;
  }): Promise<UsersDto> {
    return new Promise(async (r, errf) => {
      this.apiHandler
        .login({ email, password })
        .then((response) => {
          this.user = response.user;
          this.token = response.token;
          this.isLoggedInPriv = true;
          return r(response.user);
        })
        .catch((err) => {
          errf(err.message);
        });
    });
  }
}
