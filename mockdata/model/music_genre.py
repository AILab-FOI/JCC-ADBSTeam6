from model.model import BaseModel


class MusicGenres(BaseModel):
    musicid: int
    genreid: int

    def __init__(self,
                 Music_musicID: int,
                 Genre_genreID: int):

        self.musicid = Music_musicID
        self.genreid = Genre_genreID
