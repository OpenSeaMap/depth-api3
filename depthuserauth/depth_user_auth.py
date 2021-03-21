import logging
from django.db import connections
from django.contrib.auth.hashers import check_password
from django.contrib.auth.models import User
from org import _queryhelper, userdb_columns


def GetUserInfo(username):

    user = dict()

    with connections['osmapi'].cursor() as cursor:
        query = "select {} from user_profiles where user_name='{}'".format(_queryhelper(), username)
        cursor.execute(query)
        db_res = cursor.fetchone()
        cnt = 0
        for col_entry in userdb_columns:
            user[col_entry] = db_res[cnt]
            cnt += 1

    return user


class LoginDepthBackend(object):

    def authenticate(self, request, username=None, password=None):
        logger = logging.getLogger(__name__)
        logger.info("LoginDepthBackend::authenticate for user {}".format(username))

        # read user info from osmapi database
        userinfo = GetUserInfo(username)
        if len(userinfo) > 0:
            logger.info("user {} found in osmdb".format(username))
            login_valid = (username == userinfo["user_name"])
            password_db = userinfo["password"]

            pwd_valid = check_password(password, "sha1$$" + password_db)
            # note: sample password sha1 without salt
            # 'sha1$$7c222fb2927d828af22f592134e8932480637c0d'
            # plain: "12345678"

            if login_valid and pwd_valid:
                try:
                    user = User.objects.get(username=username)
                    logger.info("user {} found in django user db".format(username))
                except User.DoesNotExist:
                    # Create a new user. There's no need to set a password
                    # because only the password from settings.py is checked.
                    logger.info("create user {} in django user db".format(username))
                    user = User(username=username)
                    user.is_staff = False
                    user.is_superuser = False
                    user.save()
                return user
            return None

        else:
            logger.info("user {} not found in osmdb".format(username))

        return None

    # Required for the backend to work properly - unchanged in most scenarios
    def get_user(self, user_id):
        logger = logging.getLogger(__name__)
        logger.info("LoginDepthBackend::get_user(iuser_id={})".format(user_id))
        try:
            retv=User.objects.get(pk=user_id)
            logger.info("user found id={}".format(user_id))
            return retv
        except User.DoesNotExist:
            logger.info("user not found id={}".format(user_id))
            return None
