import { UsersDto } from '@/users/dto/user.dto';
import { Users } from '@/users/entities/user.entity';

export function toUserDto(user: Users): UsersDto {
  return {
    firstName: user.firstname,
    lastName: user.lastname,
    email: user.email,
    username: user.username,
    userID: user.userid,
    Roles_roleID: user?.role?.roleid || -1,
  };
}
