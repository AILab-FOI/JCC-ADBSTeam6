import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Like, Repository } from 'typeorm';
import { Artists } from '@/artists/entities/artist.entity';
import { setSkipAndTake } from '@/helpers';
import { toArtistsDto } from '@/mapper/artists.mapper';
import { toMusicDto } from '@/mapper/music.mapper';
import { toPlaylistDto } from '@/mapper/playlist.mapper';
import { toUserDto } from '@/mapper/users.mapper';
import { Music } from '@/music/entities/music.entity';
import { Playlists } from '@/playlists/entities/playlist.entity';
import { SearchResultDto } from '@/search-result.dto';
import { Users } from '@/users/entities/user.entity';

@Injectable()
export class AppService {
  constructor(
    @InjectRepository(Music) private musicRepository: Repository<Music>,
    @InjectRepository(Playlists)
    private playlistRepository: Repository<Playlists>,
    @InjectRepository(Users) private userRepository: Repository<Users>,
    @InjectRepository(Artists) private artistRepository: Repository<Artists>,
  ) {}

  getHello(): string {
    return 'Hello World!';
  }

  async searchByText(
    content: string,
    limit: number,
    offset: number,
  ): Promise<SearchResultDto> {
    if (!content) {
      return {
        titles: [],
        playlists: [],
        users: [],
        artists: [],
      };
    }

    const titles = await this.musicRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        title: Like(`%${content}%`),
      },
      relations: {
        user: true,
        genres: true,
        artists: true,
      },
    });

    const playlists = await this.playlistRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        name: Like(`%${content}%`),
      },
      relations: { user: true },
    });

    const users = await this.userRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        username: Like(`%${content}%`),
      },
    });

    const artists = await this.artistRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        name: Like(`%${content}%`),
      },
    });

    return {
      titles: titles.map(toMusicDto),
      playlists: playlists.map(toPlaylistDto),
      users: users.map(toUserDto),
      artists: artists.map(toArtistsDto),
    };
  }
}
