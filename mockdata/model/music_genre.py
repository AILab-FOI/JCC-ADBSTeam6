from model.model import BaseModel


class MusicGenre(BaseModel):
    Music_musicID: int
    Genre_genreID: int

    def __init__(self,
                 Music_musicID: int,
                 Genre_genreID: int):

        self.Music_musicID = Music_musicID
        self.Genre_genreID = Genre_genreID
