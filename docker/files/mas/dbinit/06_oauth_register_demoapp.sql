#!/bin/bash
#
# Script to register the L7 Demo Blog App with the OAuth Toolkit
#
# From command line run as root: mysql -u ssg_oauth -p ssg_oauth_toolkit < oauth_register_demoapp.sql
#
# 2013-03-06
#
USE otk_db;

-- Insert a default client for testing the APNs demo blog app client
-- 
DELETE FROM oauth_client WHERE client_ident = '791e500a-185b-4c83-a35c-f7d97a7be5ed';
DELETE FROM oauth_client_key WHERE client_ident = '791e500a-185b-4c83-a35c-f7d97a7be5ed';

INSERT INTO oauth_client (client_ident, name, description, organization, registered_by, type, custom)
VALUES ('791e500a-185b-4c83-a35c-f7d97a7be5ed', 'Layer7 Blog Demo App', 'OAuth 2.0 iOS test blog client running as native app', 'Layer7 Technologies Inc.', 'admin', 'confidential', '{}');
INSERT INTO oauth_client_key (client_key, secret, status, created_by, client_ident, client_name, callback, scope, custom)
VALUES ('l7BlogiOSApp-20', 'l7BlogClientSecret-20', 'ENABLED', 'admin', '791e500a-185b-4c83-a35c-f7d97a7be5ed', 'Layer7 Blog Demo App', 'http-com-layer7-blogdemo://callback', 'oob', '{}');