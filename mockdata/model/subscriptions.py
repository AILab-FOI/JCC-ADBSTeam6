from model.model import BaseModel


class Subscriptions(BaseModel):
    userID: int
    subscribeToID: int

    def __init__(self, userID: int, subscribeToID: int):
        self.userID = userID
        self.subscribeToID = subscribeToID
