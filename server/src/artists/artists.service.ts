import { setSkipAndTake } from '@/helpers';
import { toArtistsDto } from '@/mapper/artists.mapper';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FindManyOptions, Repository } from 'typeorm';
import { ArtistsDto } from './dto/artist.dto';
import { CreateArtistDto } from './dto/create-artist.dto';
import { UpdateArtistDto } from './dto/update-artist.dto';
import { Artists } from './entities/artist.entity';

@Injectable()
export class ArtistsService {
  constructor(
    @InjectRepository(Artists) private artistsRepository: Repository<Artists>,
  ) {}

  create(createArtistDto: CreateArtistDto) {
    return 'This action adds a new artist';
  }

  async findAll(limit: number, offset: number): Promise<ArtistsDto[]> {
    const artistList = await this.artistsRepository.find(
      setSkipAndTake({ limit, offset }),
    );

    return artistList.map(toArtistsDto);
  }

  async findByMusicId(musicId: number): Promise<ArtistsDto[]> {
    const artists = await this.artistsRepository.find({
      where: {
        music: {
          musicid: musicId,
        },
      },
      relations: {
        music: true,
      },
    });

    return artists.map(toArtistsDto);
  }

  async findOne(id: number) {
    const artist = await this.artistsRepository.findOne({
      where: { artistid: id },
    });
    if (!artist) return null;

    return toArtistsDto(artist);
  }

  update(id: number, updateArtistDto: UpdateArtistDto) {
    return `This action updates a #${id} artist`;
  }

  remove(id: number) {
    return `This action removes a #${id} artist`;
  }
}
