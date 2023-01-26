import {
  BeforeInsert,
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Comments } from '@/comments/entities/comment.entity';
import { Music } from '@/music/entities/music.entity';
import { Playlists } from '@/playlists/entities/playlist.entity';
import { Subscriptions } from '@/subscriptions/entities/subscription.entity';
import { Roles } from '@/roles/entities/role.entity';
import * as bcrypt from 'bcrypt';

// @Index('solomail', ['email'], { unique: true })
// @Index('users_pkey', ['userid'], { unique: true })
@Entity('users', { schema: 'public' })
export class Users {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'userid' })
  userid: number;

  @Column('character varying', { name: 'username', length: 45 })
  username: string;

  @Column('character varying', { name: 'email', unique: true, length: 45 })
  email: string;

  @Column('character varying', { name: 'firstname', length: 30 })
  firstname: string;

  @Column('character varying', { name: 'lastname', length: 30 })
  lastname: string;

  @Column('character varying', {
    name: 'password',
    nullable: false,
    length: 64,
  })
  password: string;

  @OneToMany(() => Comments, (comments) => comments.user)
  comments: Comments[];

  @OneToMany(() => Music, (music) => music.user)
  music: Music[];

  @OneToMany(() => Playlists, (playlists) => playlists.user)
  playlists: Playlists[];

  @OneToMany(() => Subscriptions, (subscriptions) => subscriptions.subscribeto)
  subscriptions: Subscriptions[];

  @OneToMany(() => Subscriptions, (subscriptions) => subscriptions.user)
  subscriptions2: Subscriptions[];

  @ManyToOne(() => Roles, (roles) => roles.users, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'roleid', referencedColumnName: 'roleid' }])
  role: Roles;

  @BeforeInsert()
  async hashPassword() {
    this.password = await bcrypt.hash(this.password, 10);
  }
}
