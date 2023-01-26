import { PartialType } from '@nestjs/mapped-types';
import { CreatePlaylistMusicDto } from './create-playlist-music.dto';

export class UpdatePlaylistMusicDto extends PartialType(CreatePlaylistMusicDto) {}
