from typing import Optional

from westmarches_utils.api.abstract import AbstractApi
from westmarches_utils.api.auth import AbstractClientAuth
from westmarches_utils.api.config import WestMarchesApiConfig
from westmarches_utils.api.discord import DiscordUser
from westmarches_utils.api.exception import HTTPException, ServerException, ClientException
from westmarches_utils.api.management import ManagementApi


class UsersApi(AbstractApi):

    def __init__(self, endpoint: str, auth: Optional[AbstractClientAuth] = None) -> None:
        super().__init__(endpoint + '/users', auth)

    async def findOne(self, query: Optional[object] = None, default=None):
        return await self.find_one(query, default)


class WestMarchesApi(AbstractApi):

    def __init__(self, config: "WestMarchesApiConfig") -> None:
        super().__init__(config.api_endpoint, config.api_auth)

        self._management = ManagementApi(config.mgmnt_api_endpoint, config.management_api_auth)
        self._users = UsersApi(config.api_endpoint, config.api_auth)

    @property
    def management(self):
        return self._management

    @property
    def users(self):
        return self._users
