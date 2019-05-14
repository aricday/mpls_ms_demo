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

USE mag_db;

-- MAG/ MSSO test device data:
--
DELETE FROM mag_device_app WHERE magidentifier = 'magidentifier01';
DELETE FROM mag_device_app WHERE magidentifier = 'magidentifier02';
DELETE FROM mag_device_app WHERE magidentifier = 'magidentifier04';
DELETE FROM mag_device_app WHERE magidentifier = 'magidentifier06';

DELETE FROM mag_msso_device WHERE magidentifier = 'magidentifier01';
DELETE FROM mag_msso_device WHERE magidentifier = 'magidentifier02';
DELETE FROM mag_msso_device WHERE magidentifier = 'magidentifier03';
DELETE FROM mag_msso_device WHERE magidentifier = 'magidentifier04';
DELETE FROM mag_msso_device WHERE magidentifier = 'magidentifier06';

INSERT INTO mag_msso_device (certdn,magidentifier,username,deviceid,devicename,devicestatus,created,updated,multiuser)
VALUES ('certdn01', 'magidentifier01', 'username01', 'deviceid01', 'devicename01', 'activated',(unix_timestamp()+86400),(unix_timestamp()+86400),"TRUE");
INSERT INTO mag_msso_device (certdn,magidentifier,username,deviceid,devicename,devicestatus,created,updated,multiuser)
VALUES ('certdn02', 'magidentifier02', 'username01', 'deviceid02', 'devicename02', 'activated',(unix_timestamp()+86400),(unix_timestamp()+86400),"TRUE");
INSERT INTO mag_msso_device (certdn,magidentifier,username,deviceid,devicename,devicestatus,created,updated,multiuser)
VALUES ('certdn06', 'magidentifier06', 'username02', 'deviceid06', 'devicename06', 'registered',(unix_timestamp()+86400),(unix_timestamp()+86400),"TRUE");

-- insert a device which is not used anywhere
INSERT INTO mag_msso_device (certdn, magidentifier,username,deviceid,devicename,devicestatus,created,updated,multiuser)
VALUES('certdn03','magidentifier03','username01','deviceid03','devicename03','activated',(unix_timestamp()+86400),(unix_timestamp()+86400),"TRUE");

-- insert a device which is not used anywhere which is using an expried app
INSERT INTO mag_msso_device (certdn, magidentifier,username,deviceid,devicename,devicestatus,created,updated,multiuser)
VALUES('certdn04','magidentifier04','username01','deviceid04','devicename04','activated',(unix_timestamp()+86400),(unix_timestamp()+86400),"TRUE");

INSERT INTO mag_device_app (magidentifier,client_key,access_token)
VALUES('magidentifier01', 'client_key01', 'access_token01');

INSERT INTO mag_device_app (magidentifier,client_key,access_token)
VALUES('magidentifier01', 'client_key02', 'access_token05');

INSERT INTO mag_device_app (magidentifier,client_key,access_token)
VALUES('magidentifier02', 'client_key01', 'access_token02');

INSERT INTO mag_device_app (magidentifier,client_key,access_token)
VALUES('magidentifier06', 'client_key01', 'access_token06');

-- insert an access_token for magidentifier02 which is not valid anymore
INSERT INTO mag_device_app (magidentifier,client_key,access_token)
VALUES('magidentifier02', 'client_key02', 'access_token04');

-- for the device which is not used anywhere which is using an expired app
INSERT INTO mag_device_app (magidentifier,client_key,access_token)
VALUES('magidentifier04', 'client_key01', 'access_token04');