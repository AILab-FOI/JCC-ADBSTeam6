import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Playlistmusic } from '@/playlist-musics/entities/playlist-music.entity';
import { Users } from '@/users/entities/user.entity';

// @Index('playlists_pkey', ['playlistid'], { unique: true })
@Entity('playlists', { schema: 'public' })
export class Playlists {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'playlistid' })
  playlistid: number;

  @Column('character varying', { name: 'name', length: 40 })
  name: string;

  @Column('text', { name: 'description', nullable: true })
  description: string | null;

  @OneToMany(() => Playlistmusic, (playlistmusic) => playlistmusic.playlist)
  playlistmusics: Playlistmusic[];

  @ManyToOne(() => Users, (users) => users.playlists, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'userid', referencedColumnName: 'userid' }])
  user: Users;
}
