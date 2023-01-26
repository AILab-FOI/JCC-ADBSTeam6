import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Music } from '@/music/entities/music.entity';
import { Users } from '@/users/entities/user.entity';

// @Index('comments_pkey', ['commentid'], { unique: true })
@Entity('comments', { schema: 'public' })
export class Comments {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'commentid' })
  commentid: number;

  @Column('text', { name: 'content' })
  content: string;

  @ManyToOne(() => Music, (music) => music.comments, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'musicid', referencedColumnName: 'musicid' }])
  music: Music;

  @ManyToOne(() => Users, (users) => users.comments, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'userid', referencedColumnName: 'userid' }])
  user: Users;
}
