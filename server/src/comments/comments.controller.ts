import { JwtAuthGuard } from '@/auth/jwt-auth.guard';
import { extractLimitOffset } from '@/helpers';
import { UsersDto } from '@/users/dto/user.dto';
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UsePipes,
  UseGuards,
  ValidationPipe,
  Req,
} from '@nestjs/common';
import { CommentsService } from './comments.service';
import { CommentsDto } from './dto/comment.dto';
import { CreateCommentDto } from './dto/create-comment.dto';
import { UpdateCommentDto } from './dto/update-comment.dto';

@Controller('api/comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @UsePipes(ValidationPipe)
  create(
    @Body() createCommentDto: CreateCommentDto,
    @Req() req: { user: UsersDto },
  ) {
    return this.commentsService.create(createCommentDto, req.user);
  }

  @Get()
  findAll() {
    return this.commentsService.findAll();
  }

  @Get('/user/:id')
  findByUserId(@Param('id') userId: string, @Query() query) {
    const { limit, offset } = extractLimitOffset(query);

    return this.commentsService.findByUserId(+userId, limit, offset);
  }
  @Get('/music/:id')
  findByMusicId(
    @Param('id') musicId: string,
    @Query() query,
  ): Promise<CommentsDto[]> {
    const { limit, offset } = extractLimitOffset(query);

    return this.commentsService.findByMusicId(+musicId, limit, offset);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.commentsService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateCommentDto: UpdateCommentDto) {
    return this.commentsService.update(+id, updateCommentDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  remove(@Param('id') id: string, @Req() req: { user: UsersDto }) {
    return this.commentsService.remove(+id, req.user);
  }
}
