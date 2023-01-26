from model.model import BaseModel


class Artists(BaseModel):
    artistID: int
    name: str

    def __init__(self, artistID: int,
                 name: str):

        self.artistID = artistID
        self.name = name

    def id(self) -> int: return self.artistID
