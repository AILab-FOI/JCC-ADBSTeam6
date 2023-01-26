import {
  Column,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Users } from '@/users/entities/user.entity';

// @Index('roles_pkey', ['roleid'], { unique: true })
@Entity('roles', { schema: 'public' })
export class Roles {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'roleid' })
  roleid: number;

  @Column('character varying', { name: 'name', nullable: true, length: 15 })
  name: string | null;

  @OneToMany(() => Users, (users) => users.role)
  users: Users[];
}
