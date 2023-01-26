import { setSkipAndTake } from '@/helpers';
import { toGenresDto } from '@/mapper/genres.mapper';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FindManyOptions, Repository } from 'typeorm';
import { CreateGenreDto } from './dto/create-genre.dto';
import { GenresDto } from './dto/genres.dto';
import { UpdateGenreDto } from './dto/update-genre.dto';
import { Genres } from './entities/genre.entity';

@Injectable()
export class GenresService {
  constructor(
    @InjectRepository(Genres) private genreRepository: Repository<Genres>,
  ) {}

  create(createGenreDto: CreateGenreDto) {
    return 'This action adds a new genre';
  }

  async findAll(limit: number, offset: number): Promise<GenresDto[]> {
    const genreList = await this.genreRepository.find(
      setSkipAndTake({ limit, offset }),
    );

    return genreList.map(toGenresDto);
  }

  async findOne(id: number) {
    return toGenresDto(
      await this.genreRepository.findOne({ where: { genreid: id } }),
    );
  }

  update(id: number, updateGenreDto: UpdateGenreDto) {
    return `This action updates a #${id} genre`;
  }

  remove(id: number) {
    return `This action removes a #${id} genre`;
  }
}
