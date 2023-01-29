from model.model import BaseModel


class Users(BaseModel):
    userID: int
    username: str
    password: str
    email: str
    firstName: str
    lastName: str
    roleid: int

    def __init__(self,
                 userID: int,
                 username: str,
                 password: str,
                 email: str,
                 firstName: str,
                 lastName: str,
                 Roles_roleID: int):

        self.userID = userID
        self.username = username
        self.password = password
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.roleid = Roles_roleID

    def id(self) -> int: return self.userID
