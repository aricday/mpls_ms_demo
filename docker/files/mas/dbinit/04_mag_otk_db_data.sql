-- CA Technologies
-- Database data for MAG
--
-- This script inserts required data to enable MAG Manager and social login
--
USE otk_db;

-- MAG Manager:
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('18661300-45df-4cdc-826f-23e402275463', 'MAG Manager', 'MAG Manager is used to manage registered devices', 'CA Technologies', 'admin', 'confidential', '{}');

-- Credentials for MAG Manager:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('18661300-45df-4cdc-826f-23e402275463', '171f6a0b-deee-44a9-89fe-8dda80b67cba', 'ENABLED', 'admin', '18661300-45df-4cdc-826f-23e402275463', 'MAG Manager', 'https://mas.docker.local:8443/mag/manager', 'openid profile email user_role', 'MAGServer', '{}');

-- OAuth Server to support 'local' social login:
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('c716ac35-ae5b-4870-bfa1-5530c65952f9', 'MAG Authorization Server', 'Used to support social login via the MAG', 'CA Technologies', 'admin', 'confidential', '{}');

-- Credentials for OAuth Server to support 'local' social magidentifier:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('c716ac35-ae5b-4870-bfa1-5530c65952f9', '269957e2-5bc0-4a59-b0b5-c37e88460159', 'ENABLED', 'admin', 'c716ac35-ae5b-4870-bfa1-5530c65952f9', 'MAG Authorization Server', 'https://mas.docker.local:8443/auth/oauth/v2/authorize/login?action=login&provider=enterprise', 'openid profile email', 'MAGServer', '{}');
