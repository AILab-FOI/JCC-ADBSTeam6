import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreatePlaylistMusicDto } from './dto/create-playlist-music.dto';
import { UpdatePlaylistMusicDto } from './dto/update-playlist-music.dto';
import { Playlistmusic } from './entities/playlist-music.entity';

@Injectable()
export class PlaylistMusicsService {
  constructor(
    @InjectRepository(Playlistmusic)
    private playlistMusicRepository: Repository<Playlistmusic>,
  ) {}

  async create(
    createPlaylistMusicDto: CreatePlaylistMusicDto,
  ): Promise<Playlistmusic> {
    const playlistmusicsOfPlaylist = await this.findAllOfPlaylist(
      createPlaylistMusicDto.playlistId,
    );

    let ordered = 1;
    if (playlistmusicsOfPlaylist.length > 0) {
      ordered = Math.max(...playlistmusicsOfPlaylist.map((a) => a.ordered)) + 1;
    }
    const playlistmusic = this.playlistMusicRepository.create({
      musicid: createPlaylistMusicDto.musicId,
      playlistid: createPlaylistMusicDto.playlistId,
      ordered,
    });

    await this.playlistMusicRepository.save(playlistmusic);

    return playlistmusic;
  }

  async findAllOfPlaylist(playlistId: number): Promise<Playlistmusic[]> {
    const playlistmusics = await this.playlistMusicRepository.find({
      where: {
        playlistid: playlistId,
      },
      relations: { music: true },
      order: {
        ordered: 'ASC',
      },
    });

    return playlistmusics;
  }

  async isIn(playlistId: number, musicId: number): Promise<boolean> {
    return !!(await this.playlistMusicRepository.findOne({
      where: {
        playlistid: playlistId,
        musicid: musicId,
      },
    }));
  }

  async remove(toDelete: CreatePlaylistMusicDto) {
    const playlistmusic = await this.playlistMusicRepository.findOne({
      where: {
        musicid: toDelete.musicId,
        playlistid: toDelete.playlistId,
      },
    });

    if (!playlistmusic) {
      throw new HttpException(
        "This music isn't in this playlist.",
        HttpStatus.BAD_REQUEST,
      );
    }

    await this.playlistMusicRepository.remove(playlistmusic);
  }
}
