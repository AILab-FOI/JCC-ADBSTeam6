from generate_data import *
from model.model import BaseModel
from typing import Sequence
from json import dumps


def get_ids(m_list: Sequence[BaseModel]):
    return list(map(lambda o: o.id(), m_list))


def sql_insert_into(*args: Sequence[BaseModel]):
    s = ""
    for m_ls in args:
        s += f"DELETE FROM {m_ls[0].__class__.__name__};\n"
        for m in m_ls:
            s += m.insert_sql_sentence() + ";\n"

    return s


def get_json(**kwargs: Sequence[BaseModel]):
    d = {}
    for k in kwargs.keys():
        d[k] = list(map(lambda o: o.__dict__, kwargs[k]))

    return dumps(d)


N_USERS = 200
N_SUBS = int(N_USERS**2/50)

N_MUSICS = 1000
N_COMMENTS = int(N_MUSICS * N_USERS / 150)
N_ARTISTS = 100
N_GENRES = 30
N_PLAYLISTS = int(N_USERS * 1.25)

N_MUSIC_ARTISTS = int(N_MUSICS * 2.5)
N_MUSIC_GENRES = int(N_MUSICS * 2.5)
N_MUSIC_PLAYLISTS = 15 * N_PLAYLISTS

roles = generate_roles(["admin", "user"])
users = generate_users(N_USERS, get_ids(roles))
subs = generate_subscriptions(N_USERS, get_ids(users))

musics = generate_music(N_MUSICS, get_ids(users))
comments = generate_comments(
    N_COMMENTS, get_ids(users), get_ids(musics))
artists = generate_artists(N_ARTISTS)
genres = generate_genres(N_GENRES)
playlists = generate_playlists(N_PLAYLISTS, get_ids(users))

music_artists = generate_music_artists(
    N_MUSIC_ARTISTS, get_ids(musics), get_ids(artists))
music_genres = generate_music_genre(
    N_MUSIC_GENRES, get_ids(musics), get_ids(genres))
music_playlists = generate_playlist_music(
    N_MUSIC_PLAYLISTS, get_ids(playlists), get_ids(musics))

pgsql = sql_insert_into(roles, users, subs, musics,
                        comments, artists, genres, playlists, music_artists, music_genres, music_playlists)

json_data = get_json(roles=roles, users=users, subscriptions=subs, musics=musics,
                     comments=comments, artists=artists, genres=genres, playlists=playlists, music_artists=music_artists, music_genres=music_genres, music_playlists=music_playlists)


with open("data_pg.sql", "w") as f:
    f.write(pgsql)

with open("data_json.json", "w") as f:
    f.write(json_data)
