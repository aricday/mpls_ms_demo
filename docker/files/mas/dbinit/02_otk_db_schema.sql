-- CA Technologies
-- Database schema for OTK
--
-- This table holds valid client application values as defined when the application was registered
--

USE otk_db;

CREATE TABLE mdc_template (
  templateId varchar(128) not null,
  htmlContent longtext not null,
  primary key (templateId),
  name varchar(128) not null COMMENT 'The associated name for the template',
  mode varchar(128) not null,
  constraint temp_name unique (name) ) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

CREATE TABLE oauth_client (
  client_ident varchar(255) primary key,
  name varchar(255) not null COMMENT 'The associated name of the application using this client_id',
  type varchar(128) not null DEFAULT 'oob' COMMENT 'used with oauth 2.0',
  description varchar(256) null,
  organization varchar(128) not null,
  registered_by varchar(128) not null,
  created bigint DEFAULT 0 not null,
  custom longtext null COMMENT 'longtext object containing custom fields',
  constraint uk_oc_name_org unique (name, organization)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

-- add IDX to oauth_client
CREATE INDEX oc_idx_clientname ON oauth_client(name);
--
-- This table holds valid client keys
--
CREATE TABLE oauth_client_key (
  client_key varchar(255) primary key COMMENT 'oauth_consumer_key or client_id',
  secret mediumtext not null COMMENT 'oauth_consumer_key_secret or client_secret or jwks or jwks_uri',
  scope varchar(4000) not null DEFAULT 'oob' COMMENT 'for oauth2, to be defined by the customer and handled accordingly within the policy',
  callback varchar(2048) not null DEFAULT 'oob' COMMENT 'in oauth2 = redirect_uri, contains one URI',
  environment varchar(128) not null DEFAULT 'ALL' COMMENT 'COULD BE SOMETHING LIKE Test, Prod, Integration',
  expiration bigint not null DEFAULT 0 COMMENT 'Date until this key is valid',
  status varchar(128) not null COMMENT 'for validation purposes, ENABLED or DISABLED',
  created bigint DEFAULT 0 not null,
  created_by varchar(128) not null,
  client_ident varchar(255) not null COMMENT 'The client that owns this key',
  client_name varchar(255) not null COMMENT 'The name of the client that owns this key. Not normalized for performance.',
  custom longtext null COMMENT 'longtext object containing custom fields',
  serviceIds varchar(256) null COMMENT 'A list of service IDs that the key is authorized for',
  accountPlanMappingIds varchar(256) null COMMENT 'Account plan associated with the client',
  constraint ock_fk_clientIdent foreign key (client_ident) references oauth_client (client_ident) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
-- Add IDX to oauth_client_key
CREATE INDEX ock_idx_clientident ON oauth_client_key(client_ident);
--
-- This table holds access_tokens and refresh_tokens
-- oauth 2.0 = access_token, refresh_token
--
CREATE TABLE oauth_token (
  otk_token_id varchar(128) primary key,
  token varchar(128) unique,
  secret varchar(128) null COMMENT 'null for oauth 2.0, it does not provide a secret',
  expiration bigint not null,
  scope varchar(4000) null COMMENT 'for 0auth 2.0, the scope granted by the resource owner',
  resource_owner varchar(128) not null COMMENT 'the authenticated user that granted the token',
  created bigint DEFAULT 0 COMMENT 'the date this token (or these tokens in oauth 2.0) were created',
  rtoken varchar(128) null unique key,
  rexpiration bigint DEFAULT 0 COMMENT 'DEFAULT 0 because otherwise timestamp will be set to now() on an update',
  status varchar(128) not null COMMENT 'for validation purposes, ENABLED or DISABLED',
  client_key varchar(255) not null COMMENT 'the client_key this token was issued for',
  client_name varchar(255) not null COMMENT 'The name of the client that owns this key. Not normalized for performance.',
  client_ident varchar(255) not null COMMENT 'Client',
  custom longtext null COMMENT 'longtext object containing custom fields'

) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
-- Adding indexes to oauth_token. This will improve the overall performance
CREATE INDEX oat_idx_expiration ON oauth_token (expiration);
CREATE INDEX oat_idx_rowner_client ON oauth_token(resource_owner,client_key);
CREATE INDEX oat_idx_rowner ON oauth_token(resource_owner);
CREATE INDEX oat_idx_client ON oauth_token(client_key);
CREATE INDEX oat_idx_rowner_client_ident ON oauth_token(resource_owner, client_ident);
--
-- This table holds temporary tokens
-- oauth 2.0 = authorization_code
--
CREATE TABLE oauth_initiate (
  token varchar(128) primary key COMMENT 'for oauth 2.0',
  secret varchar(128) null COMMENT 'null for oauth 2.0, it does not provide a secret',
  expiration bigint not null DEFAULT 0 COMMENT 'for oauth 2.0, DEFAULT 0 because otherwise timestamp will be set to now() on an update',
  scope varchar(4000) null COMMENT 'for oauth 2.0, the scope granted by the resource owner',
  resource_owner varchar(128) null COMMENT 'the authenticated user that granted the token',
  created bigint DEFAULT 0 COMMENT 'the date this token (or these tokens in oauth 2.0) were created',
  verifier varchar(128) null COMMENT 'code verifier',
  callback varchar(256) null COMMENT 'for oauth 2.0',
  client_key varchar(255) not null COMMENT 'the client that received this token',
  client_name varchar(255) not null COMMENT 'The name of the client that owns this key. Not normalized for performance.',
  custom longtext null COMMENT 'longtext object containing custom fields'
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
--
-- This table holds session info
--
CREATE TABLE oauth_session (
  session_key varchar(128) not null,
  session_group varchar(128) not null,
  expiration bigint not null,
  value mediumtext not null,
  primary key (session_key, session_group)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
--
CREATE TABLE otk_version (
  current_version char(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
INSERT INTO otk_version (current_version) VALUES ('otk4.3.1');
--
-- This table will contain all id_token
--
CREATE TABLE oauth_id_token (
  resource_owner varchar(128) not null,
  azp varchar(255) not null,
  sub varchar(255) null,
  jwt_id varchar(512) null,
  jwt mediumtext not null,
  salt varchar(384) null,
  shared_secret mediumtext null,
  shared_secret_type varchar(128) null,
  iss varchar(255) not null,
  expiration bigint not null COMMENT 'expiration date in seconds',
  constraint pk_mag_id_token primary key (resource_owner, azp)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
-- Adding indexes to oauth_id_token. This will improve the overall performance
CREATE INDEX oaidt_idx_expiration ON oauth_id_token (expiration);
CREATE INDEX oaidt_idx_azp ON oauth_id_token (azp);
--
-- CA API Portal API Keys
--
CREATE TABLE portal_apikey (
  apikey_pk varchar(255) primary key COMMENT 'id from JSON Sync message',
  apikey varchar(255) unique not null COMMENT 'key from JSON Sync message',
  apikey_secret varchar(255) not null COMMENT 'secret from JSON Sync message',
  status varchar(100) not null COMMENT 'status from JSON sync message',
  organization_id varchar(128) not null COMMENT 'organizationId from JSON sync message. Previously this was accountPlanMappingId',
  organization varchar(255) not null COMMENT 'organizationName from JSON sync message',
  label varchar(255) not null COMMENT 'label from JSON sync message',
  created_by varchar(128) not null COMMENT 'createdBy from JSON sync message',
  modified_by varchar(128) not null COMMENT 'modifiedBy from JSON sync message',
  created bigint DEFAULT 0 not null COMMENT 'the date this apikey was created, which is now in the case of it being a new one',
  updated bigint DEFAULT 0 not null COMMENT 'the date this apikey was updated, which is now',
  apis longtext null COMMENT 'apis from JSON sync message',
  value_xml longtext not null COMMENT 'Contains more or less all values again'
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
--
CREATE INDEX papikey_updated ON portal_apikey (updated);
--
--
-- Test data for an initial installation.
--
-- Delete the existing test clients to install them
--
delete from oauth_client where client_ident = '123456800-otk';
delete from oauth_client_key where client_ident = '123456800-otk';
delete from oauth_client where client_ident = '123456801-otk';
delete from oauth_client_key where client_ident = '123456801-otk';
delete from oauth_client where client_ident = 'TestClient2.0';
delete from oauth_client_key where client_ident = 'TestClient2.0';
--
-- OpenID Connect Client for the Basic Client Profile specification
--
insert into oauth_client (client_ident, name, description, organization, registered_by, type, custom)
values ('123456800-otk', 'OpenID Connect Basic Client Profile', 'Test for OpenID Connect BCP', 'CA Technologies Inc.', 'admin', 'confidential', '{}');
insert into oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
values ('5eed868e-7ad0-4172-88f2-704bcf78b61e', '2054e4d7-77f2-46c9-bc4d-11a47255a6ec', 'ENABLED', 'admin', '123456800-otk', 'OpenID Connect Basic Client Profile', 'YOUR_SSG/oauth/v2/client/bcp?auth=done', 'openid email profile phone address', '{}');
--
-- OpenID Connect Client for the Implicit Client Profile specification
--
insert into oauth_client (client_ident, name, description, organization, registered_by, type, custom)
values ('123456801-otk', 'OpenID Connect Implicit Client Profile', 'Test for OpenID Connect ICP', 'CA Technologies Inc.', 'admin', 'public', '{}');
insert into oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
values ('5edc4a38-75ec-4617-8854-1a71ff1e0a2e', '5005a669-0295-4602-be7d-6a75342db6d8', 'ENABLED', 'admin', '123456801-otk', 'OpenID Connect Implicit Client Profile', 'YOUR_SSG/oauth/v2/client/icp?auth=done', 'openid email profile phone address', '{}');
--
-- Create an OAuth 2.0 client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('TestClient2.0', 'OAuth2Client', 'OAuth 2.0 test client hosted on the ssg', 'CA Technologies Inc.', 'admin', 'confidential', '{}');
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, custom)
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'a0f2742f-31c7-436f-9802-b7015b8fd8e6', 'ENABLED', 'admin', 'TestClient2.0', 'OAuth2Client', 'YOUR_SSG/oauth/v2/client/authcode,YOUR_SSG/oauth/v2/client/implicit', '{}');

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

COMMIT;
