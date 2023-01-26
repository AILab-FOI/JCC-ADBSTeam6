import { setSkipAndTake } from '@/helpers';
import { toPlaylistDto } from '@/mapper/playlist.mapper';
import { MusicService } from '@/music/music.service';
import { PlaylistMusicsService } from '@/playlist-musics/playlist-musics.service';
import { UsersDto } from '@/users/dto/user.dto';
import {
  forwardRef,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreatePlaylistDto } from './dto/create-playlist.dto';
import { PlaylistDto } from './dto/playlist.dto';
import { UpdatePlaylistDto } from './dto/update-playlist.dto';
import { Playlists } from './entities/playlist.entity';

@Injectable()
export class PlaylistsService {
  constructor(
    @InjectRepository(Playlists)
    private playlistRepository: Repository<Playlists>,
    @Inject(forwardRef(() => MusicService))
    private musicService: MusicService,
    private playlistMusicService: PlaylistMusicsService,
  ) {}

  async create(createPlaylistDto: CreatePlaylistDto, user: UsersDto) {
    if (!user) {
      throw new HttpException(
        'User needs to be connected.',
        HttpStatus.FORBIDDEN,
      );
    }

    if (!createPlaylistDto.name) {
      throw new HttpException(
        "playlist's name needs to be specified.",
        HttpStatus.BAD_REQUEST,
      );
    }

    if (!createPlaylistDto.description) {
      throw new HttpException(
        "playlist's description needs to be specified.",
        HttpStatus.BAD_REQUEST,
      );
    }

    const playlist = this.playlistRepository.create({
      ...createPlaylistDto,
      user: { userid: user.userID },
    });

    await this.playlistRepository.save(playlist);
    return toPlaylistDto(playlist);
  }

  async findAll(limit: number, offset: number): Promise<PlaylistDto[]> {
    const playlistList = await this.playlistRepository.find({
      ...setSkipAndTake({ limit, offset }),
      relations: { user: true },
    });

    return playlistList.map(toPlaylistDto);
  }

  async findOne(id: number): Promise<PlaylistDto | null> {
    const playlist = await this.playlistRepository.findOne({
      where: { playlistid: id },
      relations: { user: true },
    });

    if (!playlist) {
      return null;
    }

    return toPlaylistDto(playlist);
  }

  async findByOwnerId(
    ownerId: number,
    limit: number,
    offset: number,
  ): Promise<PlaylistDto[]> {
    const playlistList = await this.playlistRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        user: {
          userid: ownerId,
        },
      },
      relations: {
        user: true,
      },
    });

    return playlistList.map(toPlaylistDto);
  }

  async addMusicToPlaylist(
    playlistId: number,
    musicId: number,
    user: UsersDto,
  ): Promise<void> {
    const playlist = await this.findOne(playlistId);
    if (!playlist) {
      throw new HttpException("playlist don't exists.", HttpStatus.BAD_REQUEST);
    }

    const music = await this.musicService.findOne(musicId);
    if (!music) {
      throw new HttpException("music don't exists", HttpStatus.BAD_REQUEST);
    }

    if (playlist.user.userID !== user.userID) {
      throw new HttpException(
        'You need to be the owner of the playlist to add music.',
        HttpStatus.FORBIDDEN,
      );
    }

    await this.playlistMusicService.create({
      playlistId,
      musicId,
    });
  }

  async removeMusicFromPlaylist(
    playlistId: number,
    musicId: number,
    user: UsersDto,
  ): Promise<void> {
    const playlist = await this.findOne(playlistId);
    if (!playlist) {
      throw new HttpException("playlist don't exists.", HttpStatus.BAD_REQUEST);
    }

    const music = await this.musicService.findOne(musicId);
    if (!music) {
      throw new HttpException("music don't exists", HttpStatus.BAD_REQUEST);
    }

    if (playlist.user.userID !== user.userID) {
      throw new HttpException(
        'You need to be the owner of the playlist to remove music.',
        HttpStatus.FORBIDDEN,
      );
    }

    await this.playlistMusicService.remove({
      playlistId,
      musicId,
    });
  }

  update(id: number, updatePlaylistDto: UpdatePlaylistDto) {
    return `This action updates a #${id} playlist`;
  }

  remove(id: number) {
    return `This action removes a #${id} playlist`;
  }
}
