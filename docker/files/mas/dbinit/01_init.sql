-- create gateway databases
CREATE DATABASE IF NOT EXISTS `ssg`;
CREATE USER 'gateway' IDENTIFIED BY '7layer';
GRANT ALL ON ssg.* TO 'gateway'@'%';

-- create OTK databases
CREATE DATABASE IF NOT EXISTS `otk_db`;
CREATE USER 'otk_user' IDENTIFIED BY '7layer';
GRANT ALL ON otk_db.* TO 'otk_user'@'%';

-- create MAG databases
CREATE DATABASE IF NOT EXISTS `mag_db`;
CREATE USER 'mag_user' IDENTIFIED BY '7layer';
GRANT ALL ON mag_db.* TO 'mag_user'@'%';