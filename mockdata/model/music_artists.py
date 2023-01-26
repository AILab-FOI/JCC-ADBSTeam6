from model.model import BaseModel


class MusicArtists(BaseModel):
    Music_musicID: int
    Artists_artistID: int

    def __init__(self,
                 Music_musicID: int,
                 Artists_artistID: int):

        self.Music_musicID = Music_musicID
        self.Artists_artistID = Artists_artistID
