import {
  addZero,
  randomString,
  setSkipAndTake,
  toArrayBuffer,
} from '@/helpers';
import { toMusicDto } from '@/mapper/music.mapper';
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { readFileSync, writeFileSync } from 'fs';
import * as mp3Parser from 'mp3-parser';
import { Repository } from 'typeorm';
import { MusicDto } from './dto/music.dto';
import { Music } from './entities/music.entity';
import * as dotenv from 'dotenv';
import * as mp3Duration from 'get-mp3-duration';
import { join } from 'path';
import { CreateMusicDto } from './dto/create-music.dto';
import { UsersDto } from '@/users/dto/user.dto';
import { ArtistsService } from '@/artists/artists.service';
import { GenresService } from '@/genres/genres.service';
import { UsersService } from '@/users/users.service';
import { PlaylistMusicsService } from '@/playlist-musics/playlist-musics.service';
import { KsqldbService } from '@/ksqldb/ksqldb.service';
dotenv.config();

@Injectable()
export class MusicService {
  constructor(
    @InjectRepository(Music) private musicRepository: Repository<Music>,
    private artistService: ArtistsService,
    private genreService: GenresService,
    private userService: UsersService,
    private playlistMusicsService: PlaylistMusicsService,
    private ksqldbService: KsqldbService,
  ) {}

  private async getNextMusicId(): Promise<number> {
    const nextVal = await this.musicRepository.query(
      `select nextval(\'public.music_musicid_seq\') as id;`,
    );
    console.log({ nextVal });
    return typeof nextVal[0].id === 'number'
      ? nextVal[0].id
      : Number.parseInt(nextVal[0].id);
  }

  async isLiked(musicId: number, user: UsersDto) {
    const likePlaylist = await this.userService.findUserLikesPlaylist(
      user.userID,
    );
    if (!likePlaylist) {
      throw new HttpException(
        'Missing likes playlist of user.',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    return this.playlistMusicsService.isIn(likePlaylist.playlistID, musicId);
  }

  async findByArtistId(
    artistId: number,
    limit: number,
    offset: number,
  ): Promise<MusicDto[]> {
    const musics = await this.musicRepository.find({
      where: {
        artists: {
          artistid: artistId,
        },
      },
      relations: {
        user: true,
        genres: true,
        artists: true,
      },
      ...setSkipAndTake({ limit, offset }),
    });

    return musics.map(toMusicDto);
  }

  async likeMusic(musicId: number, user: UsersDto): Promise<void> {
    const music = await this.musicRepository.findOne({
      where: { musicid: musicId },
    });
    if (!music) {
      throw new HttpException("Music don't exists", HttpStatus.BAD_REQUEST);
    }

    const likePlaylist = await this.userService.findUserLikesPlaylist(
      user.userID,
    );
    if (!likePlaylist) {
      throw new HttpException(
        'Missing likes playlist of user.',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    if (
      await this.playlistMusicsService.isIn(likePlaylist.playlistID, musicId)
    ) {
      throw new HttpException(
        'Music have already been liked.',
        HttpStatus.BAD_REQUEST,
      );
    }

    this.playlistMusicsService.create({
      playlistId: likePlaylist.playlistID,
      musicId,
    });

    this.ksqldbService.addLike(musicId);
  }

  async unlikeMusic(musicId: number, user: UsersDto): Promise<void> {
    const music = await this.musicRepository.findOne({
      where: { musicid: musicId },
    });
    if (!music) {
      throw new HttpException("Music don't exists", HttpStatus.BAD_REQUEST);
    }

    const likePlaylist = await this.userService.findUserLikesPlaylist(
      user.userID,
    );
    if (!likePlaylist) {
      throw new HttpException(
        'Missing likes playlist of user.',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    if (
      !(await this.playlistMusicsService.isIn(likePlaylist.playlistID, musicId))
    ) {
      throw new HttpException(
        'Music have not been liked yet.',
        HttpStatus.BAD_REQUEST,
      );
    }

    this.playlistMusicsService.remove({
      playlistId: likePlaylist.playlistID,
      musicId,
    });

    this.ksqldbService.removeLike(musicId);
  }

  async delete(musicId: number, userId: number): Promise<MusicDto | null> {
    const music = await this.musicRepository.findOne({
      where: { musicid: musicId },
      relations: {
        genres: true,
        artists: true,
        comments: true,
        user: true,
      },
    });
    if (!music) return null;

    if (music.user.userid !== userId) {
      throw new HttpException(
        "You cannot delete a music that isn't yours.",
        HttpStatus.FORBIDDEN,
      );
    }

    await this.musicRepository.delete({ musicid: musicId });
    return toMusicDto(music);
  }

  async create(
    file: Express.Multer.File,
    createMusic: CreateMusicDto,
    user: UsersDto,
  ): Promise<MusicDto> {
    if (file.mimetype !== 'audio/mpeg') {
      throw new HttpException(
        "Incorrect mimetype. Expected 'audio/mpeg', got " + file.mimetype + '.',
        HttpStatus.BAD_REQUEST,
      );
    }

    const filepath = join(
      process.env.AUDIO_FILE_DIRPATH,
      `${createMusic.title.replace(' ', '_')}-${randomString(8)}.mp3`,
    );
    const arrayBuffer = toArrayBuffer(file.buffer);

    writeFileSync(filepath, new DataView(arrayBuffer));

    for (const artistId of createMusic.artists) {
      const artist = await this.artistService.findOne(artistId);
      if (!artist)
        throw new HttpException(
          `artist with id ${artistId} don't exists.`,
          HttpStatus.BAD_REQUEST,
        );
    }

    for (const genreId of createMusic.genres) {
      const genre = await this.genreService.findOne(genreId);
      if (!genre)
        throw new HttpException(
          `genre with id ${genreId} don't exists.`,
          HttpStatus.BAD_REQUEST,
        );
    }

    const duration = (await mp3Duration(file.buffer)) / 1000;

    const musicid = await this.getNextMusicId();

    const music = this.musicRepository.create({
      file: filepath,
      musicid,
      title: createMusic.title,
      description: createMusic.title,
      turnoffcomments: createMusic.turnoffcomments,
      publicationdate: new Date(),
      link: '',
      artists: createMusic.artists.map((a) => ({ artistid: a })),
      genres: createMusic.genres.map((a) => ({ genreid: a })),
      user: {
        userid: user.userID,
      },
      duration: `${Math.floor(duration / 60)}:${addZero(
        Math.round(duration % 60),
      )}`,
    });

    await this.musicRepository.save(music);
    return toMusicDto(music);
  }

  async findHits(limit: number, offset: number): Promise<MusicDto[]> {
    // TODO: sort the music list according to views and like. Need to implements some methods in KsqldbConenction.

    const musicList = await this.musicRepository.find({
      ...setSkipAndTake({ limit, offset }),
      relations: {
        user: true,
        genres: true,
        artists: true,
      },
    });

    return musicList.map(toMusicDto);
  }

  async fetchMusicBlock(
    musicId: number,
    blockNumber: number,
    NBlocks: number,
  ): Promise<Uint8Array | null> {
    const music = await this.musicRepository.findOne({
      where: { musicid: musicId },
    });
    if (!music || !music.file) {
      throw new HttpException(
        "Music don't exists or file is absent.",
        HttpStatus.BAD_REQUEST,
      );
    }

    const buffer: Buffer = readFileSync(music.file);
    const arrayBuffer: ArrayBuffer = toArrayBuffer(buffer);
    const dataView = new DataView(arrayBuffer);

    const startAt = mp3Parser.readId3v2Tag(dataView)?._section?.byteLength || 0;
    let i = startAt;
    let start = mp3Parser.readFrame(dataView, i);
    console.log({ startAt });

    while (!start) {
      i++;
      start = mp3Parser.readFrame(dataView, i);
    }

    for (let j = 0; j < blockNumber; j++) {
      start = mp3Parser.readFrame(dataView, start._section.nextFrameIndex);
    }

    let end = start;
    for (
      let j = 0;
      j < NBlocks && mp3Parser.readFrame(dataView, end._section.nextFrameIndex);
      j++
    ) {
      end = mp3Parser.readFrame(dataView, end._section.nextFrameIndex);
    }

    const returnArrayBuffer = arrayBuffer.slice(
      start._section.offset,
      // Math.min(
      end._section.offset + end._section.byteLength,
      // buffer.byteLength,
      // ),
    );

    return new Uint8Array(returnArrayBuffer);
  }

  async findByPlaylistId(
    playlistId: number,
    limit: number,
    offset: number,
  ): Promise<MusicDto[]> {
    const musics = await this.musicRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        playlistmusics: {
          playlistid: playlistId,
        },
      },
      relations: {
        user: true,
        genres: true,
        artists: true,
      },
    });

    return musics.map(toMusicDto);
  }

  async findOne(id: number): Promise<MusicDto | null> {
    const music = await this.musicRepository.findOne({
      where: {
        musicid: id,
      },
      relations: {
        user: true,
        genres: true,
        artists: true,
      },
    });

    if (!music) return null;

    return toMusicDto(music);
  }

  async findByGenreId(
    genreId: number,
    limit: number,
    offset: number,
  ): Promise<MusicDto[]> {
    const musics = await this.musicRepository.find({
      where: {
        genres: {
          genreid: genreId,
        },
      },
      relations: {
        user: true,
        genres: true,
        artists: true,
      },
      ...setSkipAndTake({ limit, offset }),
    });

    return musics.map(toMusicDto);
  }
}
