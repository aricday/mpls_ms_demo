# pylint: disable=broad-except,invalid-name,wrong-import-position
"""
    This sample client will simulate a mobile device registration flow for
    PasswordGrant and PasswordGrant with OTP
"""
import os
import sys
import argparse
from http import HTTPStatus
from flask import Flask, jsonify, g, request
from functools import wraps
import jwt
from jwt.algorithms import RSAAlgorithm
import simplejson as json
from urllib.parse import urlparse
import logging

sys.path.insert(0, os.path.dirname(
    os.path.realpath(__file__)) + '/../')

from lib.utils import http_status_response, fetch_jwks, PythonObjectEncoder # noqa
from config.service import CA_JWK_HEADER_NAME # noqa

APP_SECRET_KEY = os.urandom(32)
JWKS = fetch_jwks()

logger = logging.getLogger(__name__)


def jwt_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not request.headers.get(CA_JWK_HEADER_NAME):
            message = "'%s' header required" % CA_JWK_HEADER_NAME
            logger.warn(message)
            return jsonify(errors=[message],
                           **http_status_response('BAD_REQUEST')
                           ), HTTPStatus.BAD_REQUEST.value
        g.jwt = request.headers.get(CA_JWK_HEADER_NAME)
        valid = False
        errors = list()
        url = urlparse(request.url)
        audience = '%s://%s' % (url.scheme, url.netloc)
        # Try to fetch JWKS once more
        if not g.jwks:
            g.jwks = fetch_jwks()
        for jwk in g.jwks:
            secret = RSAAlgorithm('SHA256').from_jwk(json.dumps(jwk))
            try:
                g.jwt_decoded = jwt.decode(g.jwt, secret, audience=audience)
            except (jwt.exceptions.InvalidIssuedAtError,
                    jwt.exceptions.InvalidAudienceError,
                    jwt.exceptions.ExpiredSignatureError) as error:
                logger.warn(error)
                errors.append(str(error))
                continue
            except jwt.exceptions.DecodeError as error:
                logger.warn(error)
                errors.append("JSON format error: '%s'" % g.jwt)
                continue
            valid = True
            break
        if not valid:
            logger.warn(errors)
            return jsonify(errors=errors, **http_status_response('BAD_REQUEST')
                           ), HTTPStatus.BAD_REQUEST.value
        return f(*args, **kwargs)
    return decorated_function


def create_app():
    """ dynamically create the app """
    app = Flask(__name__)
    app.config.from_object(__name__)
    app.secret_key = APP_SECRET_KEY
    app.json_encoder = PythonObjectEncoder

    @app.before_request
    def before_request():
        """ create the db_client global if it does not exist """
        if not hasattr(g, 'jwks'):
            g.jwks = JWKS

    def default_error_handle(error=None):
        """ create a default json error handle """
        return jsonify(errors=[str(error)], message=error.description,
                       success=False), error.code

    # handle all errors with json output
    for error in list(range(400, 420)) + list(range(500, 506)):
        if error not in [402, 407, 419]:  # not all are keys in app.errorhandler
            app.errorhandler(error)(default_error_handle)

    # add each api Blueprint and create the base route
    from root.views import root
    app.register_blueprint(root, url_prefix="")
    return app


def bootstrap(**kwargs):
    """bootstraps the application. can handle setup here"""
    app = create_app()
    app.debug = True
    app.run(host=kwargs['host'], port=kwargs['port'], threaded=True)

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.DEBUG,
        format=("%(asctime)s %(levelname)s %(name)s[%(process)s] : %(funcName)s"
                " : %(message)s"),
    )
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", help="Hostname or IP address", dest="host",
                        type=str, default='0.0.0.0')
    parser.add_argument("--port", help="Port number", dest="port", type=int,
                        default=8000)
    args = parser.parse_args()
    bootstrap(**args.__dict__)