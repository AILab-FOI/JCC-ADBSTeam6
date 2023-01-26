from model.model import BaseModel


class Roles(BaseModel):
    roleID: int
    name: str

    def __init__(self, roleID: int,
                 name: str):

        self.roleID = roleID
        self.name = name

    def id(self) -> int: return self.roleID
