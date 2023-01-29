from model.model import BaseModel


class PlaylistMusic(BaseModel):
    playlistid: int
    musicid: int
    ordered: int

    def __init__(self,
                 Playlists_playlistID: int,
                 Music_musicID: int,
                 ordered: int):

        self.playlistid = Playlists_playlistID
        self.musicid = Music_musicID
        self.ordered = ordered
