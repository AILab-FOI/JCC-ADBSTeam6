import { HttpService } from '@nestjs/axios';
import { Inject, Injectable, Logger } from '@nestjs/common';
import { ClientKafka } from '@nestjs/microservices';
import { catchError, map, Observable } from 'rxjs';
import { MusicStatsPayloadDto } from './dto/MusicStatsPayload.dto';

type KsqldbHeaderType = {
  header: {
    queryId: string;
    schema: string;
  };
};

type KsqldbDataType = {
  row: {
    columns: any[];
  };
};

type KsqldbQueryType = [KsqldbHeaderType, ...KsqldbDataType[]];

@Injectable()
export class KsqldbService {
  private logger = new Logger('KSQLDB');
  private URL = 'http://localhost:8088/';

  constructor(private http: HttpService) {}

  private convertHttpQueryToObject(
    columns: string[],
    data: any[],
  ): { [key: (typeof columns)[number]]: any } {
    const o = {};
    for (let i = 0; i < columns.length; i++) {
      o[columns[i]] = data[i];
    }

    return o;
  }

  private getDataFromKsqldbQuery(
    response: KsqldbQueryType,
  ): { [key: string]: any }[] {
    const [{ header }, ...data] = response;

    const columnsExtract = /`(.*?)`/g;

    const columns = header.schema
      .match(columnsExtract)
      .map((s) => s.replaceAll('`', ''));
    return data.map((a) =>
      this.convertHttpQueryToObject(columns, a.row.columns),
    );
  }

  private queryObservable(sql: string): Observable<{ [key: string]: any }[]> {
    return this.http
      .post(
        this.URL + 'query',
        {
          ksql: sql,
          streamProperties: {},
        },
        {
          headers: {
            Accept: 'application/vnd.ksql.v1+json',
          },
        },
      )
      .pipe(
        catchError((error) => {
          this.logger.error(error);
          throw error.message;
        }),
        map((res) => this.getDataFromKsqldbQuery(res.data)),
      );
  }

  private ksqlObservable(sql: string): Observable<unknown> {
    return this.http
      .post(
        this.URL + 'ksql',
        {
          ksql: sql,
          streamProperties: {},
        },
        {
          headers: {
            Accept: 'application/vnd.ksql.v1+json',
          },
        },
      )
      .pipe(
        catchError((error) => {
          this.logger.error(error.response.data);
          throw error.message;
        }),
      );
  }

  async hasMusicStatFor(musicId: number): Promise<boolean> {
    return new Promise((resolve) => {
      this.queryObservable(
        `SELECT * FROM LikesMusic WHERE musicId=${musicId};`,
      ).subscribe((data) => {
        resolve(data.length > 0);
      });
    });
  }

  async initMusicStatFor(musicId: number): Promise<void> {
    this.ksqlObservable(
      `INSERT INTO MusicData (musicId,views,likes) VALUES (${musicId},0,0);`,
    ).subscribe();
  }

  /**
   * return the stats of a music specified by id.
   * Error handling: If no stats is found, it means that there is no data for it, so we init the data.
   *
   * @param musicId music's id
   * @returns the payload
   */
  async findOneMusicStat(musicId: number): Promise<MusicStatsPayloadDto> {
    const likes = await new Promise<number>(async (resolve) => {
      this.queryObservable(
        `SELECT * FROM LikesMusic WHERE musicId=${musicId};`,
      ).subscribe((data) => {
        if (data.length === 0) {
          this.logger.warn(
            `No views stats for music with id ${musicId}. Automatically init new stats.` +
              musicId,
          );
          this.initMusicStatFor(musicId);
          return resolve(0);
        }
        resolve(data[0]['MUSICLIKES']);
      });
    });

    const views = await new Promise<number>(async (resolve) => {
      this.queryObservable(
        `SELECT * FROM ViewsMusic WHERE musicId=${musicId};`,
      ).subscribe((data) => {
        if (data.length === 0) {
          this.logger.warn(
            `No views stats for music with id ${musicId}. Automatically init new stats.` +
              musicId,
          );
          this.initMusicStatFor(musicId);
          return resolve(0);
        }
        resolve(data[0]['MUSICVIEWS']);
      });
    });

    return { musicId, views, likes };
  }

  async addLike(musicId: number): Promise<void> {
    const { views, likes } = await this.findOneMusicStat(musicId);
    this.ksqlObservable(
      `INSERT INTO MusicData   (
         musicId,  likes, views
      )
      VALUES (
         ${musicId}, ${likes + 1}, ${views}
      );`,
    ).subscribe();
  }

  async removeLike(musicId: number): Promise<void> {
    const { views, likes } = await this.findOneMusicStat(musicId);
    this.ksqlObservable(
      `INSERT INTO MusicData   (
         musicId,  likes, views
      )
      VALUES (
         ${musicId}, ${likes - 1}, ${views}
      );`,
    ).subscribe();
  }

  async view(musicId: number): Promise<void> {
    const { views, likes } = await this.findOneMusicStat(musicId);
    this.ksqlObservable(
      `INSERT INTO MusicData   (
         musicId,  likes, views
      )
      VALUES (
         ${musicId}, ${likes}, ${views + 1}
      );`,
    ).subscribe();
  }
}
