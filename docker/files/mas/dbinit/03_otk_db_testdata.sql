-- CA Technologies.
-- Database test data for OTK
--
-- This script is used to create OAuth default test clients for testing purposes in non-production environments.
--
-- To install it run a command on the linux root shell similiar to this:
-- mysql -u root -p 'your-otk-database' < otk_db_testdata.sql
-- e.g.: mysql -u root -p ssg_oauth_toolkit < /home/ssgconfig/otk_db_testdata.sql

use otk_db;

-- Delete the existing test clients to install them
--
delete from oauth_client where client_ident = '123456800-otk';
delete from oauth_client_key where client_ident = '123456800-otk';
delete from oauth_client where client_ident = '123456801-otk';
delete from oauth_client_key where client_ident = '123456801-otk';
delete from oauth_client where client_ident = 'TestClient1.0';
delete from oauth_client_key where client_ident = '1234TestClient1.0';
delete from oauth_client where client_ident = 'TestClient2.0';
delete from oauth_client_key where client_ident = 'TestClient2.0';
--
-- OpenID Connect Client for the Basic Client Profile specification
--
insert into oauth_client (client_ident, name, description, organization, registered_by, type, custom)
values ('123456800-otk', 'OpenID Connect Basic Client Profile', 'Test for OpenID Connect BCP', 'Layer7 Technologies Inc.', 'admin', 'confidential', '{}');
insert into oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
values ('5eed868e-7ad0-4172-88f2-704bcf78b61e', '2054e4d7-77f2-46c9-bc4d-11a47255a6ec', 'ENABLED', 'admin', '123456800-otk', 'OpenID Connect Basic Client Profile', 'YOUR_SSG/oauth/v2/client/bcp?auth=done', 'openid email profile phone address', '{}');
--
-- OpenID Connect Client for the Implicit Client Profile specification
--
insert into oauth_client (client_ident, name, description, organization, registered_by, type, custom)
values ('123456801-otk', 'OpenID Connect Implicit Client Profile', 'Test for OpenID Connect ICP', 'Layer7 Technologies Inc.', 'admin', 'public', '{}');
insert into oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
values ('5edc4a38-75ec-4617-8854-1a71ff1e0a2e', '5005a669-0295-4602-be7d-6a75342db6d8', 'ENABLED', 'admin', '123456801-otk', 'OpenID Connect Implicit Client Profile', 'YOUR_SSG/oauth/v2/client/icp?auth=done', 'openid email profile phone address', '{}');
--
-- Create an OAuth 1.0 and OAuth 2.0 client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, custom)
VALUES ('TestClient1.0', 'OAuth1Client', 'OAuth 1.0 test client hosted on the ssg', 'Layer7 Technologies Inc.', 'admin', '{}');

INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('TestClient2.0', 'OAuth2Client', 'OAuth 2.0 test client hosted on the ssg', 'Layer7 Technologies Inc.', 'admin', 'confidential', '{}');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, custom)
VALUES ('acf89db2-994e-427b-ac2c-88e6101f9433', '74d5e0db-cd8b-4d8e-a989-95a0746c3343', 'ENABLED', 'admin', 'TestClient1.0', 'OAuth1Client', '{}');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, custom)
VALUES ('54f0c455-4d80-421f-82ca-9194df24859d', 'a0f2742f-31c7-436f-9802-b7015b8fd8e6', 'ENABLED', 'admin', 'TestClient2.0', 'OAuth2Client', 'https://mas.docker.local:443/oauth/v2/client/authcode?auth=done,https://mas.docker.local:443/oauth/v2/client/implicit?auth=done', '{}');

--
-- Create MDC client
--
INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('0daffd5c-d8b8-46f3-b38f-3f617624e591', 'Developer Console Access', 'Client used by the Developer Console', 'CA Technologies Inc.', 'admin', 'public', '{}');

INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, scope, callback, custom)
VALUES ('0daffd5c-d8b8-46f3-b38f-3f617624e591', 'e62afc98-7b87-11e6-9288-0fe490372cd1', 'ENABLED', 'admin', '0daffd5c-d8b8-46f3-b38f-3f617624e591', 'Developer Console Access', 'openid profile email name address devconsole', 'https://mas.docker.local:443', '{}');
--

