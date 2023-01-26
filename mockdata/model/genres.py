from model.model import BaseModel


class Genres(BaseModel):
    tagID: int
    name: str

    def __init__(self, tagID: int,
                 name: str):
        self.tagID = tagID
        self.name = name

    def id(self) -> int: return self.tagID
