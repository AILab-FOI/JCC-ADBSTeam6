from model.model import BaseModel


class PlaylistMusic(BaseModel):
    Playlists_playlistID: int
    Music_musicID: int
    order: int

    def __init__(self,
                 Playlists_playlistID: int,
                 Music_musicID: int,
                 order: int):

        self.Playlists_playlistID = Playlists_playlistID
        self.Music_musicID = Music_musicID
        self.order = order
