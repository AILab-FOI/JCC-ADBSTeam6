from model.model import BaseModel


class MusicArtists(BaseModel):
    musicid: int
    artistid: int

    def __init__(self,
                 Music_musicID: int,
                 Artists_artistID: int):

        self.musicid = Music_musicID
        self.artistid = Artists_artistID
