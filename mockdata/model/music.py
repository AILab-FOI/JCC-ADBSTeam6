from model.model import BaseModel


class Music(BaseModel):
    musicID: int
    title: str
    description: str
    publicationDate: str
    turnOffComments: int
    file: str
    duration: str
    userid: int
    link: str

    def __init__(self, musicID: int,
                 title: str,
                 description: str,
                 publicationDate: str,
                 turnOffComments: int,
                 file: str,
                 duration: str,
                 link: str,
                 Users_userID: int):

        self.musicID = musicID
        self.title = title
        self.description = description
        self.publicationDate = publicationDate
        self.turnOffComments = turnOffComments
        self.file = file
        self.link = link
        self.duration = duration
        self.userid = Users_userID

    def id(self) -> int: return self.musicID
