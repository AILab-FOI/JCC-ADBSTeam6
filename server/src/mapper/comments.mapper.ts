import { CommentsDto } from '@/comments/dto/comment.dto';
import { Comments } from '@/comments/entities/comment.entity';

export function toCommentsDto(comments: Comments): CommentsDto {
  return {
    commentID: comments.commentid,
    content: comments.content,
    Users_userID: comments.user.userid,
    Music_musicID: comments.music.musicid,
  };
}
