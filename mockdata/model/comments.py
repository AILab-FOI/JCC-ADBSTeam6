from model.model import BaseModel


class Comments(BaseModel):
    commentID: int
    content: str
    Users_userID: int
    Music_musicID: int

    def __init__(self,
                 commentID: int,
                 content: str,
                 Users_userID: int,
                 Music_musicID: int):

        self.commentID = commentID
        self.content = content
        self.Users_userID = Users_userID
        self.Music_musicID = Music_musicID

    def id(self) -> int: return self.commentID
