import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Music } from '@/music/entities/music.entity';
import { Playlists } from '@/playlists/entities/playlist.entity';

// @Index('playlistmusic_pkey', ['musicid', 'playlistid'], { unique: true })
@Entity('playlistmusic', { schema: 'public' })
export class Playlistmusic {
  @Column('integer', { primary: true, name: 'playlistid', nullable: false })
  playlistid: number;

  @Column('integer', { primary: true, name: 'musicid', nullable: false })
  musicid: number;

  @PrimaryGeneratedColumn({ type: 'integer', name: 'ordered' })
  ordered: number;

  @ManyToOne(() => Music, (music) => music.playlistmusics, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'musicid', referencedColumnName: 'musicid' }])
  music: Music;

  @ManyToOne(() => Playlists, (playlists) => playlists.playlistmusics, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'playlistid', referencedColumnName: 'playlistid' }])
  playlist: Playlists;
}
