import { UsersDto } from 'src/types/api-dto/UsersDto';

export interface IAuthService {
  isLoggedIn(): boolean;

  getUser(): UsersDto | null;

  getToken(): string | null;

  login({
    email,
    password,
  }: {
    email: string;
    password: string;
  }): Promise<UsersDto>;

  disconnect(): Promise<void>;

  register({
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
  }): Promise<UsersDto>;
}
