# pylint: disable=broad-except,invalid-name
"""
    Flask API Utils
"""
import os
import sys
from http import HTTPStatus
import functools
import simplejson as json
import logging
import base64
import requests
import socket

sys.path.insert(0, os.path.dirname(
    os.path.realpath(__file__)) + '/../../')

from config.service import MSGW_JWKS_URL, MSGW_JWKS_URL_USERNAME, \
    MSGW_JWKS_URL_PASSWORD, MSGW_OAUTH_TOKEN_EXCHANGE_URL # noqa

logger = logging.getLogger(__name__)


def fetch_jwks():
    """ fetch the jwks from the MSGW JWK URL """
    url = MSGW_JWKS_URL
    credentials = "%s:%s" % (MSGW_JWKS_URL_USERNAME, MSGW_JWKS_URL_PASSWORD)
    authorization = "Basic %s" % base64.b64encode(credentials.encode()).decode()
    headers = {
        'Authorization': authorization
        }
    response = None
    try:
        response = requests.get(url, headers=headers, verify=False)
        return response.json()['keys']
    except requests.exceptions.ConnectionError as error:
        logger.critical(error)
    except Exception as error:
        logger.critical(error)
    return None


def fetch_jwt(jwt, audience):
    """ fetch the jwt from OAauth Token Exchange """
    url = MSGW_OAUTH_TOKEN_EXCHANGE_URL
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        }
    params = {
        'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
        'subject_token_type': 'urn:ietf:params:oauth:token-type:jwt',
        'subject_token': jwt,
        'audience': audience
    }
    try:
        response = requests.post(url, headers=headers, params=params,
                                 verify=False)
        return response.json()['access_token']
    except requests.exceptions.ConnectionError as error:
        logger.critical(error)
    except Exception as error:
        logger.critical(error)
    return None


def get_fqdn():
    """ get the default fqdn with socket """
    return socket.getfqdn()


def get_ip_address():
    """ get the default ip_address with socket """
    try:
        return socket.gethostbyname(socket.getfqdn())
    except socket.gaierror as error:
        logger.warn(error)
    return socket.gethostbyname("")


def http_status_response(enum_name):
    """ create a custom HTTPStatus response dictionary """
    if not getattr(HTTPStatus, enum_name):
        return {}
    return {
        'code': getattr(HTTPStatus, enum_name).value,
        'status': getattr(HTTPStatus, enum_name).phrase,
        'description': getattr(HTTPStatus, enum_name).description
    }


def rsetattr(obj, attr, val):
    pre, _, post = attr.rpartition('.')
    return setattr(rgetattr(obj, pre) if pre else obj, post, val)

sentinel = object()


def rgetattr(obj, attr, default=sentinel):
    if default is sentinel:
        _getattr = getattr
    else:
        def _getattr(obj, name):
            return getattr(obj, name, default)
    return functools.reduce(_getattr, [obj]+attr.split('.'))


class PythonObjectEncoder(json.JSONEncoder):
    """ custom json.JSONEncoder for requests """

    def default(self, obj):
        """ default method """
        if isinstance(obj, (list, dict, str, int, float, bool, type(None))):
            return json.JSONEncoder.default(self, obj)
        if isinstance(obj, set):
            return list(obj)