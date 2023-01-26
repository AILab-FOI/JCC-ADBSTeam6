import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Music } from '@/music/entities/music.entity';

// @Index('genres_pkey', ['genreid'], { unique: true })
@Entity('genres', { schema: 'public' })
export class Genres {
  @PrimaryGeneratedColumn({ type: 'integer', name: 'genreid' })
  genreid: number;

  @Column('character varying', { name: 'name', length: 45 })
  name: string;

  @ManyToMany(() => Music, (music) => music.genres)
  @JoinTable({
    name: 'musicgenres',
    joinColumns: [{ name: 'genreid', referencedColumnName: 'genreid' }],
    inverseJoinColumns: [{ name: 'musicid', referencedColumnName: 'musicid' }],
    schema: 'public',
  })
  music: Music[];
}
