from model.model import BaseModel


class Playlists(BaseModel):
    playlistID: int
    name: str
    description: str
    Users_userID: int

    def __init__(self, playlistID: int,
                 name: str,
                 description: str,
                 Users_userID: int):

        self.playlistID = playlistID
        self.name = name
        self.description = description
        self.Users_userID = Users_userID

    def id(self) -> int: return self.playlistID
