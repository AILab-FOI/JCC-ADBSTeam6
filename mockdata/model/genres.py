from model.model import BaseModel


class Genres(BaseModel):
    genreid: int
    name: str

    def __init__(self, tagID: int,
                 name: str):
        self.genreid = tagID
        self.name = name

    def id(self) -> int: return self.genreid
