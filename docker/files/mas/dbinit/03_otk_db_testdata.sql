-- CA Technologies.
-- Database test data for OTK
--
-- This script is used to create OAuth default test clients for testing purposes in non-production environments.
--
-- To install it run a command on the linux root shell similiar to this:
-- mysql -u root -p 'your-otk-database' < otk_db_testdata.sql
-- e.g.: mysql -u root -p ssg_oauth_toolkit < /home/ssgconfig/otk_db_testdata.sql

-- Delete the existing test clients to install them
--
Use otk_db;

delete from oauth_client where client_ident = '123456800-otk';
delete from oauth_client_key where client_ident = '123456800-otk';
delete from oauth_client where client_ident = '123456801-otk';
delete from oauth_client_key where client_ident = '123456801-otk';
delete from oauth_client where client_ident = 'TestClient2.0';
delete from oauth_client_key where client_ident = 'TestClient2.0';
delete from oauth_client where client_ident = '2dc86f35-773c-47e2-958f-3f4bdfc5ea3a';
delete from oauth_client_key where client_ident = '2dc86f35-773c-47e2-958f-3f4bdfc5ea3a';
--
-- OpenID Connect Client for the Basic Client Profile specification
--
insert into oauth_client (client_ident, name, description, organization, registered_by, type, custom)
values ('123456800-otk', 'OpenID Connect Basic Client Profile', 'Test for OpenID Connect BCP', 'CA Technologies Inc.', 'admin', 'confidential', '{}');
insert into oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
values ('5eed868e-7ad0-4172-88f2-704bcf78b61e', '2054e4d7-77f2-46c9-bc4d-11a47255a6ec', 'ENABLED', 'admin', '123456800-otk', 'OpenID Connect Basic Client Profile', 'https://mas.docker.local:8443/oauth/v2/client/bcp?auth=done', 'openid email profile phone address', '{}');
--
-- OpenID Connect Client for the Implicit Client Profile specification
--
insert into oauth_client (client_ident, name, description, organization, registered_by, type, custom)
values ('123456801-otk', 'OpenID Connect Implicit Client Profile', 'Test for OpenID Connect ICP', 'CA Technologies Inc.', 'admin', 'public', '{}');
insert into oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
values ('5edc4a38-75ec-4617-8854-1a71ff1e0a2e', '5005a669-0295-4602-be7d-6a75342db6d8', 'ENABLED', 'admin', '123456801-otk', 'OpenID Connect Implicit Client Profile', 'https://mas.docker.local:8443/oauth/v2/client/icp?auth=done', 'openid email profile phone address', '{}');
--
-- Create an OAuth 2.0 client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('TestClient2.0', 'OAuth2Client', 'OAuth 2.0 test client hosted on the ssg', 'CA Technologies Inc.', 'admin', 'confidential', '{}');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, custom)
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'a0f2742f-31c7-436f-9802-b7015b8fd8e6', 'ENABLED', 'admin', 'TestClient2.0', 'OAuth2Client', 'https://mas.docker.local:8443/oauth/v2/client/authcode?auth=done,https://mas.docker.local:8443/oauth/v2/client/implicit?auth=done', '{}');
--
--
-- Create MDC client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('0daffd5c-d8b8-46f3-b38f-3f617624e591', 'Developer Console Access', 'Client used by the Developer Console', 'CA Technologies Inc.', 'admin', 'public', '{}');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, scope, callback, custom)
VALUES ('0daffd5c-d8b8-46f3-b38f-3f617624e591', 'e62afc98-7b87-11e6-9288-0fe490372cd1', 'ENABLED', 'admin', '0daffd5c-d8b8-46f3-b38f-3f617624e591', 'Developer Console Access', 'openid profile email name address devconsole', 'https://mas.docker.local:443', '{}');
--
--
-- Swagger OAuth2 Client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('2dc86f35-773c-47e2-958f-3f4bdfc5ea3a', 'Swagger OAuth2 Client', 'Swagger API testing', 'CA Technologies Inc.', 'admin', 'public', '{}');
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
VALUES ('2dc86f35-773c-47e2-958f-3f4bdfc5ea3a', '6aa6b190-056d-4a80-8604-79d9e44896ef', 'ENABLED', 'admin', '2dc86f35-773c-47e2-958f-3f4bdfc5ea3a', 'Swagger OAuth2 Client', 'YOUR_SWAGGER_SERVER/oauth2-redirect.html', 'openid email profile phone address', '{
    "openid_registration": {
        "request": {},
        "response": {
            "client_id": "2dc86f35-773c-47e2-958f-3f4bdfc5ea3a",
            "client_secret": "6aa6b190-056d-4a80-8604-79d9e44896ef",
            "client_secret_expires_at": "0",
            "client_id_issued_at": 0,
            "registration_access_token": "",
            "registration_client_uri": "",
            "token_endpoint_auth_method": "client_secret_basic",
            "token_endpoint_auth_signing_alg": "",
            "application_type": "",
            "redirect_uris": [
                "YOUR_SWAGGER_SERVER/oauth2-redirect.html"
            ],
            "client_name": "Swagger OAuth2 Client",
            "subject_type": "pairwise",
            "sector_identifier_uri": "",
            "contacts": [],
            "response_types": [
                "code",
                "implicit",
                "token"
            ],
            "grant_types": [],
            "id_token_signed_response_alg": "HS256",
            "userinfo_signed_response_alg": "",
            "environment": "ALL",
            "organization": "CA Technologies Inc.",
            "master": false,
            "description": "Swagger API testing",
            "scope": "openid email profile phone address",
            "jwks": "",
            "jwks_uri": ""
        }
    }
}');