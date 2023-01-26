import { Controller, Get, Query } from '@nestjs/common';
import { AppService } from './app.service';
import { extractLimitOffset } from './helpers';
import { SearchResultDto } from './search-result.dto';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  /**
   * /search/?q=<str>&limit=<int?>&offset=<int?>
   */
  @Get('api/search/')
  searchByText(
    @Query() query: { [key: string]: string },
  ): Promise<SearchResultDto> {
    const { limit, offset } = extractLimitOffset(query);
    const content = query.q;

    return this.appService.searchByText(content, limit, offset);
  }
}
