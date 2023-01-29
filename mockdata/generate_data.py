from typing import Dict, NewType, List, TypeVar, Any, Callable, Type
from random import choice, randint
import model as m
from data import *

SpecificationDict = NewType(
    "SpecificationDict", Dict[str, Callable[[], Any]])

T = TypeVar("T")


def choice_wrapper(ls: List[Any]) -> Callable[[], Any]:
    def f() -> Any:
        return choice(ls)

    return f


def generate_data(N: int, spec: SpecificationDict, new_class: Type[T]) -> List[T]:
    """
    generate list of instance of model from specification.
    """

    ls = []
    for _ in range(N):
        d = {}
        for k in spec.keys():
            d[k] = spec[k]()

        c = new_class(**d)  # type: ignore
        ls.append(c)

    return ls


def generate_users(N: int, roles_id: List[int]) -> List[m.Users]:
    id = [100]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f() -> int:
            ref[0] += 1
            return ref[0]

        return f

    def rdm_username() -> str:
        return f"{choice(firstnames)[0]}{choice(lastnames)[:3]}{randint(0, 500)}"

    def rdm_email() -> str:
        return f"{choice(firstnames)}.{choice(lastnames)}{randint(0, 500)}@example.org"

    spec = SpecificationDict({
        "userID": next_id(id),
        "username": rdm_username,
        "password": rdm_username,
        "email": rdm_email,
        "firstName": choice_wrapper(firstnames),
        "lastName": choice_wrapper(lastnames),
        "Roles_roleID": choice_wrapper(roles_id)
    })

    return generate_data(N, spec, m.Users)


def generate_subscriptions(N: int, users_id: List[int]) -> List[m.Subscriptions]:
    assert N < len(users_id) * (len(users_id) - 1)

    spec = SpecificationDict({
        "userID": choice_wrapper(users_id),
        "subscribeToID": choice_wrapper(users_id),
    })

    data = generate_data(N, spec, m.Subscriptions)
    data = list(filter(lambda sub: sub.userID != sub.subscribeToID, data))

    return data


def generate_roles(role_names: List[str]) -> List[m.Roles]:
    id = [0]
    name_count = [0]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f():
            ref[0] += 1
            return ref[0]

        return f

    def next_name(ref: List[int]) -> Callable[[], str]:
        def f() -> str:
            ref[0] += 1
            return role_names[ref[0] - 1]

        return f

    spec = SpecificationDict({"roleID": next_id(
        id), "name": next_name(name_count)})

    return generate_data(len(role_names), spec, m.Roles)


def generate_playlists(N: int, users_id: List[int]) -> List[m.Playlists]:
    id = [len(users_id) * 5]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f() -> int:
            ref[0] += 1
            return ref[0]

        return f

    def rdm_name() -> str:
        return f"Playlist-{randint(0, 200)}"

    def rdm_str() -> str:
        return "".join([choice("azertyuiopqsdfghklmwxcvbn") for _ in range(randint(5, 50))])

    spec = SpecificationDict({
        "playlistID": next_id(id),
        "name": rdm_name,
        "description": rdm_str,
        "Users_userID": choice_wrapper(users_id)})

    return generate_data(N, spec, m.Playlists)


def generate_comments(N: int, users_id: List[int], musics_id: List[int]) -> List[m.Comments]:
    id = [100]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f() -> int:
            ref[0] += 1
            return ref[0]

        return f

    def rdm_str() -> str:
        return "".join([choice("azertyuiopqsdfghklmwxcvbn") for _ in range(randint(5, 50))])

    spec = SpecificationDict({
        "commentID": next_id(id),
        "content": rdm_str,
        "Users_userID": choice_wrapper(users_id),
        "Music_musicID": choice_wrapper(musics_id)
    })

    return generate_data(N, spec, m.Comments)


def generate_artists(N: int) -> List[m.Artists]:
    id = [0]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f() -> int:
            ref[0] += 1
            return ref[0]

        return f

    def rdm_name() -> str:
        return f"{choice(firstnames)[0]}{choice(lastnames)[:3]}{randint(0, 500)}"

    spec = SpecificationDict({
        "artistID": next_id(id),
        "name": rdm_name
    })

    return generate_data(N, spec, m.Artists)


def generate_music_artists(N: int, musics_id: List[int], artists_id: List[int]) -> List[m.MusicArtists]:
    spec = SpecificationDict({
        "Music_musicID": choice_wrapper(musics_id),
        "Artists_artistID": choice_wrapper(artists_id),
    })

    return generate_data(N, spec, m.MusicArtists)


def generate_genres(N: int) -> List[m.Genres]:
    id = [0]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f() -> int:
            ref[0] += 1
            return ref[0]

        return f

    def rdm_name() -> str:
        return f"{choice(firstnames)[0]}{choice(lastnames)[:3]}{randint(0, 500)}"

    spec = SpecificationDict({
        "tagID": next_id(id),
        "name": rdm_name
    })

    return generate_data(N, spec, m.Genres)


def generate_music_genre(N: int, musics_id: List[int], genres_id: List[int]) -> List[m.MusicGenres]:
    spec = SpecificationDict({
        "Music_musicID": choice_wrapper(musics_id),
        "Genre_genreID": choice_wrapper(genres_id)
    })

    return generate_data(N, spec, m.MusicGenres)


def generate_music(N: int, users_id: List[int]) -> List[m.Music]:
    id = [100]

    def next_id(ref: List[int]) -> Callable[[], int]:
        def f() -> int:
            ref[0] += 1
            return ref[0]

        return f

    def rdm_str(N: int) -> Callable[[], str]:
        def f():
            return "".join([choice("azertyuiopqsdfghklmwxcvbn") for _ in range(N)])

        return f

    def rdm_int() -> int:
        return randint(0, 100)

    def rdm_music_time() -> str:
        minute = randint(1, 6)
        seconds = randint(0, 59)

        if seconds < 10:
            return f"0:0{minute}:0{seconds}"

        return f"0:0{minute}:{seconds}"

    def random_date() -> str:
        day = randint(1, 28)
        month = randint(1, 12)
        year = randint(1980, 2021)

        return f"{year}-{month}-{day}"

    f = choice(musicfiles)

    spec = SpecificationDict({
        "musicID": next_id(id),
        "title":  rdm_str(10),
        "description": lambda: f"From file: {f}",
        "Users_userID": choice_wrapper(users_id),
        "file": lambda: f,
        "link": lambda: "",
        "duration": rdm_music_time,
        "publicationDate": random_date,
        "turnOffComments": lambda: 0,
    })

    return generate_data(N, spec, m.Music)


def generate_playlist_music(N: int, playlists_id: List[int], musics_id: List[int]) -> List[m.PlaylistMusic]:
    """
    Here we need to word aroud sice, to establish a valid order, we need to add a 'state' to our selection function.
    """
    order_dict = {k: 0 for k in playlists_id}
    choosed_playlist_ids = [choice(playlists_id) for _ in range(N)]
    index_order = [0]
    index_playlist = [0]

    def next_order(ref: List[int]) -> Callable[[], int]:
        def f():
            ref[0] += 1
            order_dict[choosed_playlist_ids[ref[0] - 1]] += 1
            return order_dict[choosed_playlist_ids[ref[0] - 1]]

        return f

    def next_playlist_id(ref: List[int]) -> Callable[[], int]:
        def f():
            ref[0] += 1
            return choosed_playlist_ids[ref[0] - 1]

        return f

    spec = SpecificationDict({
        "Playlists_playlistID": next_playlist_id(index_playlist),
        "ordered": next_order(index_order),
        "Music_musicID": choice_wrapper(musics_id)
    })

    return generate_data(N, spec, m.PlaylistMusic)
