# pylint: disable=broad-except,invalid-name
"""
    Configuration
"""
import os

CURRENT_DIR = os.path.realpath(os.path.join(os.getcwd(),
                               os.path.dirname(__file__)))

# API configuration:

# MSGW configuration:
# TODO import msso_config.json instead of individual environment variables
MSGW_HOSTNAME = os.getenv('MSGW_HOSTNAME', 'localhost')
MSGW_SSL_PORT = int(os.getenv('MSGW_SSL_PORT', 9443))
MSGW_HOST = '%s:%i' % (MSGW_HOSTNAME, MSGW_SSL_PORT)
CA_JWK_HEADER_NAME = 'x-ca-jwt'
MSGW_JWKS_URL = 'https://%s/quickstart/1.0/jwks.json' % MSGW_HOST
MSGW_JWKS_URL_USERNAME = os.getenv('MSGW_JWKS_URL_USERNAME', 'admin')
MSGW_JWKS_URL_PASSWORD = os.getenv('MSGW_JWKS_URL_PASSWORD', 'password')
MSGW_OAUTH_TOKEN_EXCHANGE_URL = 'https://%s/auth/oauth/v2/token/exchange' \
                            % MSGW_HOST

# OAuth (MAS/OTK) configuration:
OAUTH_HOSTNAME = os.getenv('OAUTH_HOSTNAME', 'localhost')
OAUTH_SSL_PORT = int(os.getenv('OAUTH_SSL_PORT', 8443))
OAUTH_HOST = '%s:%i' % (OAUTH_HOSTNAME, OAUTH_SSL_PORT)
INITIALIZE_URL = 'https://%s/connect/client/initialize' % OAUTH_HOST
REGISTRATION_URL = 'https://%s/connect/device/register' % OAUTH_HOST
OAUTH_TOKEN_URL = 'https://%s/auth/oauth/v2/token' % OAUTH_HOST
