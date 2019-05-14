-- CA Technologies
-- Database test data for MAG
--
-- This script inserts test data. It is not necessary but recommended to install this script in non-production environments.
-- It is provided for testing purposes only.
--
-- run this command on a ssg command line: mysql -u root 'your_otk_database' < 'this_script'
-- rm: 'your_otk_database' needs to include the tables of the script 'mag_db_schema.sql'
--
-- Mobile test client installation:
--
USE otk_db;

DELETE FROM oauth_client WHERE client_ident = '6438edb0-3e74-mag-test-msso-clientAppA';
DELETE FROM oauth_client WHERE client_ident = '6438edb0-3e74-mag-test-msso-clientAppB';
DELETE FROM oauth_client WHERE client_ident = '6438edb0-3e74-mag-test-msso-clientAppC';
DELETE FROM oauth_client_key WHERE client_key = '6438edb0-3e74-48b6-8f08-9034140bd797';
DELETE FROM oauth_client_key WHERE client_key = '3f27bb4f-b5aa-458b-962b-14d352b7977c';
DELETE FROM oauth_client_key WHERE client_key = '68d155e9-1402-48a2-9750-e5d9f0746e17';
DELETE FROM oauth_client_key WHERE client_key = 'e53378b6-a07d-4c22-89da-8088f443fa95';
DELETE FROM oauth_client_key WHERE client_key = '8298bc51-f242-4c6d-b547-d1d8e8519cb4';

-- Testapp AppA:
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('6438edb0-3e74-mag-test-msso-clientAppA', 'AppA', 'Example application for Mobile SSO demonstrations', 'CA Technologies', 'admin', 'confidential', '{}');
-- Credentials for AppA used with iOS:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('6438edb0-3e74-48b6-8f08-9034140bd797', '6438edb0-3e74-48b6-8f08-9034140bd797', 'ENABLED', 'admin', '6438edb0-3e74-mag-test-msso-clientAppA', 'AppA', 'https://ios.ssosdk.ca.com/ios', 'openid msso phone profile address email msso_register', 'iOS', '{}');
-- Credentials for AppA used with Android:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('3f27bb4f-b5aa-458b-962b-14d352b7977c', '3f27bb4f-b5aa-458b-962b-14d352b7977c', 'ENABLED', 'admin', '6438edb0-3e74-mag-test-msso-clientAppA', 'AppA', 'https://android.ssosdk.ca.com/android', 'openid msso phone profile address email msso_register', 'Android', '{}');

-- Testapp AppB:
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('6438edb0-3e74-mag-test-msso-clientAppB', 'AppB', 'Example application for Mobile SSO demonstrations', 'CA Technologies', 'admin', 'confidential', '{}');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('7c1f4b13-3813-4d8a-91cf-cba60d668fd4', '7c1f4b13-3813-4d8a-91cf-cba60d668fd4', 'ENABLED', 'admin', '6438edb0-3e74-mag-test-msso-clientAppB', 'AppB', 'https://android.ssosdk.ca.com/android', 'openid msso phone profile address email msso_register', 'Android', '{}');
-- Credentials for AppB used with iOS:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('68d155e9-1402-48a2-9750-e5d9f0746e17', '68d155e9-1402-48a2-9750-e5d9f0746e17', 'ENABLED', 'admin', '6438edb0-3e74-mag-test-msso-clientAppB', 'AppB', 'https://ios.ssosdk.ca.com/ios', 'openid msso phone profile address email msso_register', 'iOS', '{}');

-- Testapp AppC:
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('6438edb0-3e74-mag-test-msso-clientAppC', 'AppC', 'PhoneGap example application for Mobile SSO demonstrations', 'CA Technologies', 'admin', 'confidential', '{}');
-- Credentials for AppC used with iOS:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('e53378b6-a07d-4c22-89da-8088f443fa95', 'e53378b6-a07d-4c22-89da-8088f443fa95', 'ENABLED', 'admin', '6438edb0-3e74-mag-test-msso-clientAppC', 'AppC', 'https://ios.ssosdk.ca.com/ios', 'openid msso phone profile address email msso_register', 'iOS', '{}');
-- Credentials for AppC used with Android:
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, environment, custom)
VALUES ('8298bc51-f242-4c6d-b547-d1d8e8519cb4', '8298bc51-f242-4c6d-b547-d1d8e8519cb4', 'ENABLED', 'admin', '6438edb0-3e74-mag-test-msso-clientAppC', 'AppC', 'https://android.ssosdk.ca.com/android', 'openid msso phone profile address email msso_register', 'Android', '{}');

DELETE FROM oauth_token WHERE token = 'access_token01';
DELETE FROM oauth_token WHERE token = 'access_token02';
DELETE FROM oauth_token WHERE token = 'access_token05';
DELETE FROM oauth_token WHERE token = 'access_token06';

INSERT INTO oauth_id_token (resource_owner,azp,sub,jwt,salt,shared_secret,shared_secret_type,iss,expiration)
VALUES('username01','magidentifier01','sub01','jwt01','salt01','shared_secret01','shared_secret_type01','iss01',(unix_timestamp()+86400));

INSERT INTO oauth_id_token (resource_owner,azp,sub,jwt,salt,shared_secret,shared_secret_type,iss,expiration)
VALUES('username01','magidentifier02','sub02','jwt02','salt01','shared_secret02','shared_secret_type02','iss01',(unix_timestamp()+86400));

INSERT INTO oauth_id_token (resource_owner,azp,sub,jwt,salt,shared_secret,shared_secret_type,iss,expiration)
VALUES('username02','magidentifier06','sub06','jwt06','salt06','shared_secret06','shared_secret_type06','iss06',(unix_timestamp()+86400));

INSERT INTO oauth_token (otk_token_id, token, scope, status, client_name, expiration, resource_owner, client_key, client_ident)
VALUES ('access_token01', 'access_token01', 'scope01','ENABLED', 'client_name01',(unix_timestamp()+3600),'testbuddy1','client_key01', 'client_ident01');
INSERT INTO oauth_token (otk_token_id, token, scope, status, client_name, expiration, resource_owner, client_key, client_ident)
VALUES ('access_token02', 'access_token02', 'scope02','ENABLED', 'client_name02',(unix_timestamp()+3600),'testbuddy2','client_key01', 'client_ident02');
INSERT INTO oauth_token (otk_token_id, token, scope, status, client_name, expiration, resource_owner, client_key, client_ident)
VALUES ('access_token05', 'access_token05', 'scope02','ENABLED', 'client_name02',(unix_timestamp()+3600),'testbuddy5','client_key02', 'client_ident02');
INSERT INTO oauth_token (otk_token_id, token, scope, status, client_name, expiration, resource_owner, client_key, client_ident)
VALUES ('access_token06', 'access_token06', 'scope06','ENABLED', 'client_name02',(unix_timestamp()+3600),'testbuddy6','client_key01', 'client_ident02');
