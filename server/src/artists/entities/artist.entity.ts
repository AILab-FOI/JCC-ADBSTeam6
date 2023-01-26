import {
  Column,
  Entity,
  Index,
  JoinTable,
  ManyToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Music } from '@/music/entities/music.entity';

// @Index('artists_pkey', ['artistid'], { unique: true })
@Entity('artists', { schema: 'public' })
export class Artists {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'artistid' })
  artistid: number;

  @Column('character varying', { name: 'name', nullable: true, length: 45 })
  name: string | null;

  @ManyToMany(() => Music, (music) => music.artists)
  @JoinTable({
    name: 'musicartists',
    joinColumns: [{ name: 'artistid', referencedColumnName: 'artistid' }],
    inverseJoinColumns: [{ name: 'musicid', referencedColumnName: 'musicid' }],
    schema: 'public',
  })
  music: Music[];
}
