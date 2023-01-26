import { setSkipAndTake } from '@/helpers';
import { toCommentsDto } from '@/mapper/comments.mapper';
import { UsersDto } from '@/users/dto/user.dto';
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommentsDto } from './dto/comment.dto';
import { CreateCommentDto } from './dto/create-comment.dto';
import { UpdateCommentDto } from './dto/update-comment.dto';
import { Comments } from './entities/comment.entity';

@Injectable()
export class CommentsService {
  constructor(
    @InjectRepository(Comments)
    private commentsRepository: Repository<Comments>,
  ) {}

  async create(
    createCommentDto: CreateCommentDto,
    user: UsersDto,
  ): Promise<CommentsDto> {
    const comment = this.commentsRepository.create({
      content: createCommentDto.content,
      music: { musicid: createCommentDto.musicId },
      user: { userid: user.userID },
    });

    const finalComment = await this.commentsRepository.save(comment);

    return toCommentsDto(finalComment);
  }

  findAll() {
    return `This action returns all comments`;
  }

  findOne(id: number) {
    return `This action returns a #${id} comment`;
  }

  async findByUserId(
    userId: number,
    limit: number,
    offset: number,
  ): Promise<CommentsDto[]> {
    const commentList = await this.commentsRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        user: {
          userid: userId,
        },
      },
      relations: {
        user: true,
        music: true,
      },
    });

    return commentList.map(toCommentsDto);
  }

  async findByMusicId(
    musicId: number,
    limit: number,
    offset: number,
  ): Promise<CommentsDto[]> {
    const commentList = await this.commentsRepository.find({
      ...setSkipAndTake({ limit, offset }),
      where: {
        music: {
          musicid: musicId,
        },
      },
      relations: {
        user: true,
        music: true,
      },
    });

    return commentList.map(toCommentsDto);
  }

  update(id: number, updateCommentDto: UpdateCommentDto) {
    return `This action updates a #${id} comment`;
  }

  async remove(id: number, user: UsersDto): Promise<void> {
    const comment = await this.commentsRepository.findOne({
      where: { commentid: id },
      relations: { user: true },
    });

    if (comment.user.userid !== user.userID) {
      throw new HttpException(
        "You can't delete a comment that you don't own.",
        HttpStatus.FORBIDDEN,
      );
    }

    await this.commentsRepository.delete({ commentid: comment.commentid });

    return;
  }
}
