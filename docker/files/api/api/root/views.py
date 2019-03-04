# pylint: disable=broad-except,invalid-name
"""
    views file contains all the routes for the app and maps them to a
    specific hanlders function.
"""
import os
import sys
# from datetime import datetime
from http import HTTPStatus
from flask import Blueprint, jsonify, request, g
from main import jwt_required
import requests
from urllib.parse import urlparse, unquote
import logging

sys.path.insert(0, os.path.dirname(
    os.path.realpath(__file__)) + '/../../')

from lib.utils import http_status_response, get_fqdn, get_ip_address, fetch_jwt # noqa
from config.service import CA_JWK_HEADER_NAME # noqa

logger = logging.getLogger(__name__)
root = Blueprint('main', __name__)


def sample_response(extra_data=None):
    """ sample response that is used for all resources """
    # logger.debug(request.headers.environ)
    data = {
        'host': {
            'fqdn': get_fqdn(),
            'ip_address': get_ip_address()
        },
        'extra_data': extra_data,
        'request': {
            'url': request.url
        }
    }
    if request.args.get('headers', None):
        headers = dict(((name, request.headers.get(name, None)) for name in
                        ['User-Agent', 'Authorization', CA_JWK_HEADER_NAME]))
        data['request'].update({'headers': headers})
    if request.args.get('jwt', None) and hasattr(g, 'jwt_decoded'):
            data['request'].update({'jwt': g.jwt_decoded})
    return jsonify(data=data, **http_status_response('OK')
                   ), HTTPStatus.OK.value


@root.route('/', methods=['GET'])
def index():
    """
    **Example request:**

    .. sourcecode:: http

    GET HTTP/1.1
    Accept: */*

    **Example response:**

    .. sourcecode:: http

    HTTP/1.1 200 OK
    Content-Type: application/json

    :statuscode 200: Ok
    :statuscode 500: server error
    """
    return sample_response()


@root.route('/validate', methods=['GET'])
@jwt_required
def validate():
    """
    **Example request:**

    .. sourcecode:: http

    GET HTTP/1.1
    Accept: */*

    **Example response:**

    .. sourcecode:: http

    HTTP/1.1 200 OK
    Content-Type: application/json

    :statuscode 200: Ok
    :statuscode 500: server error
    """
    return sample_response()


@root.route('/exchange', methods=['GET'])
@jwt_required
def exchange():
    """
    **Example request:**

    .. sourcecode:: http

    GET HTTP/1.1
    Accept: */*

    **Example response:**

    .. sourcecode:: http

    HTTP/1.1 200 OK
    Content-Type: application/json

    :statuscode 200: Ok
    :statuscode 500: server error
    """
    service = request.args.get('service', None)
    if service:
        service = unquote(service)
    # only for debug and development
    if not service:
        service = 'http://0.0.0.0:8000/validate'
    logger.debug(service)
    url = urlparse(service)
    audience = '%s://%s' % (url.scheme, url.netloc)
    jwt_exchange = fetch_jwt(g.jwt, audience)
    logger.debug(jwt_exchange)
    url = service
    logger.debug(url)
    headers = {
        'x-ca-jwt': jwt_exchange
        }
    extra_data = None
    try:
        response = requests.get(url, headers=headers, params=request.args,
                                verify=False)
        extra_data = response.json()
    except requests.exceptions.ConnectionError as error:
        logger.critical(error)
    except Exception as error:
        logger.critical(error)
    return sample_response(extra_data)