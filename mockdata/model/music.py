from model.model import BaseModel


class Music(BaseModel):
    musicID: int
    title: str
    description: str
    publicationDate: str
    turnOffComments: int
    link: str
    # file: str
    duration: str
    views: int
    likes: str
    Users_userID: int

    def __init__(self, musicID: int,
                 title: str,
                 description: str,
                 publicationDate: str,
                 turnOffComments: int,
                 link: str,
                 #  file: str,
                 duration: str,
                 views: int,
                 likes: str,
                 Users_userID: int):

        self.musicID = musicID
        self.title = title
        self.description = description
        self.publicationDate = publicationDate
        self.turnOffComments = turnOffComments
        self.link = link
        # self.file = file
        self.duration = duration
        self.views = views
        self.likes = likes
        self.Users_userID = Users_userID

    def id(self) -> int: return self.musicID
