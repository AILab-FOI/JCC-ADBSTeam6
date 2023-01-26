import {
  Body,
  Controller,
  Delete,
  Get,
  HttpException,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { MusicService } from './music.service';
import { extractLimitOffset } from '@/helpers';
import { MusicDto } from './dto/music.dto';
import { JwtAuthGuard } from '@/auth/jwt-auth.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { UsersDto } from '@/users/dto/user.dto';
import { InputCreateMusicDto } from './dto/input-create-music.dto';
import { toCreateMusicDto } from '@/mapper/music.mapper';
import { KsqldbService } from '@/ksqldb/ksqldb.service';

@Controller('api/music')
export class MusicController {
  constructor(
    private readonly musicService: MusicService,
    private readonly ksqldbService: KsqldbService,
  ) {}

  @Get('hits')
  fetchAllHits(@Query() query) {
    const { limit, offset } = extractLimitOffset(query);

    return this.musicService.findHits(limit, offset);
  }

  @Post('play/:id')
  playMusic(@Param('id', ParseIntPipe) musicId: number) {
    this.ksqldbService.view(musicId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  deleteMusic(
    @Param('id') musicId: number,
    @Req() req: { user: UsersDto },
  ): Promise<MusicDto | null> {
    return this.musicService.delete(+musicId, req.user.userID);
  }

  @Get('/playlist/:id')
  findByPlaylistId(
    @Param('id') playlistId: string,
    @Query() query,
  ): Promise<MusicDto[]> {
    const { limit, offset } = extractLimitOffset(query);

    return this.musicService.findByPlaylistId(+playlistId, limit, offset);
  }

  @Get(':id/is-liked')
  @UseGuards(JwtAuthGuard)
  isMusicLiked(
    @Param('id', ParseIntPipe) musicId: number,
    @Req() req: { user: UsersDto },
  ): Promise<boolean> {
    return this.musicService.isLiked(musicId, req.user);
  }

  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  likeMusic(
    @Param('id', ParseIntPipe) musicId: number,
    @Req() req: { user: UsersDto },
  ): Promise<void> {
    return this.musicService.likeMusic(musicId, req.user);
  }

  @Post(':id/unlike')
  @UseGuards(JwtAuthGuard)
  unlikeMusic(
    @Param('id') musicId: number,
    @Req() req: { user: UsersDto },
  ): Promise<void> {
    return this.musicService.unlikeMusic(musicId, req.user);
  }

  @Get('/genres/:id')
  findByGenreId(
    @Param('id') genreId: string,
    @Query() query,
  ): Promise<MusicDto[]> {
    const { limit, offset } = extractLimitOffset(query);

    return this.musicService.findByGenreId(+genreId, limit, offset);
  }

  @Get('/artist/:id')
  findByArtistId(
    @Param('id') artistId: string,
    @Query() query,
  ): Promise<MusicDto[]> {
    const { limit, offset } = extractLimitOffset(query);

    return this.musicService.findByArtistId(+artistId, limit, offset);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.musicService.findOne(+id);
  }

  /**
   * /api/music/:id/mpeg-block/?blocknumber=<int>&nblocks=<int>
   */
  @Get('/:id/mpeg-block/')
  getMPEGBlock(
    @Param('id') musicId: string,
    @Query() query,
  ): Promise<Uint8Array | null> {
    const { blocknumber, nblocks } = query;
    if (!blocknumber || !nblocks) {
      throw new HttpException(
        "Missing 'blocknumber' or 'nblocks' queryparams.",
        HttpStatus.BAD_REQUEST,
      );
    }

    return this.musicService.fetchMusicBlock(+musicId, +blocknumber, +nblocks);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('file'))
  async submitMusic(
    @UploadedFile() file: Express.Multer.File,
    @Body() data: InputCreateMusicDto,
    @Req() req: { user: UsersDto },
  ): Promise<MusicDto> {
    const music = await this.musicService.create(
      file,
      toCreateMusicDto(data),
      req.user,
    );

    return music;
  }
}
