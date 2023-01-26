from generate_data import *
from model.model import BaseModel
from typing import Sequence
from json import dumps


def get_ids(m_list: Sequence[BaseModel]):
    return list(map(lambda o: o.id(), m_list))


def sql_insert_into(*args: Sequence[BaseModel]):
    for m_ls in args:
        for m in m_ls:
            print(m.insert_sql_sentence())


def get_json(**kwargs: Sequence[BaseModel]):
    d = {}
    for k in kwargs.keys():
        d[k] = list(map(lambda o: o.__dict__, kwargs[k]))

    return dumps(d)


roles = generate_roles(["admin", "user"])
users = generate_users(3, get_ids(roles))
subs = generate_subscriptions(2, get_ids(users))

musics = generate_music(10, get_ids(users))
comments = generate_comments(6, get_ids(users), get_ids(musics))
artists = generate_artists(3)
genres = generate_genres(2)
playlists = generate_playlists(5, get_ids(users))

music_artists = generate_music_artists(10, get_ids(musics), get_ids(artists))
music_genres = generate_music_genre(10, get_ids(musics), get_ids(genres))
music_playlists = generate_playlist_music(
    6, get_ids(playlists), get_ids(musics))

sql_insert_into(roles, users, subs, musics,
                comments, artists, genres, playlists, music_artists, music_genres, music_playlists)

print(get_json(roles=roles, users=users, subscriptions=subs, musics=musics,
               comments=comments, artists=artists, genres=genres, playlists=playlists, music_artists=music_artists, music_genres=music_genres, music_playlists=music_playlists))
