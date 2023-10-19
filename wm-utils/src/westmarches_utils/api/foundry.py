from dataclasses import dataclass
from typing import Optional

from westmarches_utils.api import AbstractApi, AbstractClientAuth


@dataclass
class FoundryApiConfig:
    auth: Optional[AbstractClientAuth] = None
    endpoint: str = "http://foundry:30000"


class FoundryActivityApi(AbstractApi):

    async def get(self) -> dict:
        return (await super().get()).json()


class FoundryApi(AbstractApi):

    def __init__(self, config: "FoundryApiConfig") -> None:
        super().__init__(config.endpoint, config.auth)

        self._actors = AbstractApi(config.endpoint + '/api/actors')
        self._users = AbstractApi(config.endpoint + '/api/users')
        self._activity = FoundryActivityApi(config.endpoint + '/api/activity')

    @property
    def actors(self):
        return self._actors

    @property
    def users(self):
        return self._users

    @property
    def activity(self):
        return self._activity
