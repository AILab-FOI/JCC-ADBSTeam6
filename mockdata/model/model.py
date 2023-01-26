from json import dumps


class BaseModel():

    def id(self) -> int:
        raise NotImplemented

    def insert_sql_sentence(self) -> str:
        keys = ','.join(list(self.__dict__.keys()))
        values = ','.join(
            [f"'{self.__dict__[k]}'" for k in self.__dict__.keys()])
        return f"INSERT INTO {self.__class__.__name__} ({keys}) VALUES ({values})"

    def to_json(self) -> str:
        return dumps(self.__dict__)
