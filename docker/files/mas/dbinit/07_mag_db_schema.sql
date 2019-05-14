-- CA Technologies
-- Database schema for MAG
--
USE mag_db;

CREATE TABLE mag_msso_device (
  certdn varchar (248) not null COMMENT 'The complete DN of the cert',
  magidentifier varchar(128) not null,
  username varchar(128) not null COMMENT 'The username who registered this device',
  deviceid varchar(128) not null,
  devicename varchar(128) not null,
  devicestatus varchar (32) not null,
  created bigint not null DEFAULT 0 COMMENT 'the date this device was registered',
  updated bigint not null DEFAULT 0 COMMENT 'the date this device registration was updated',
  multiuser varchar(32) null COMMENT 'indicates whether this device provides multiuser support',
  csr_base64 mediumtext null COMMENT 'the certificate signing request used when device first registered',
  signed_cert_base64 mediumtext null COMMENT 'the currently active base64 encoded ca_msso signed cert',
  grace_expiration bigint not null DEFAULT 0 COMMENT 'This is the grace expiry date of the device certificate, it is calculated based on certificate expiry + configured accept_expiry time period',
  constraint uk_mag_msso_device_dn unique (certdn),
  constraint uk_mag_msso_device_id unique (deviceid),
  constraint pk_msso_device primary key (magidentifier)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

CREATE INDEX device_status_index ON mag_msso_device(devicestatus);
CREATE INDEX device_username_index ON mag_msso_device(username);

CREATE TABLE mag_device_app (
  magidentifier varchar(128) not null,
  client_key varchar(255) not null,
  access_token varchar(128) not null,
  constraint pk_mag_device_app primary key (magidentifier, client_key),
  constraint fk_mag_device_app foreign key (magidentifier) references mag_msso_device (magidentifier) on delete cascade
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
CREATE INDEX mda_magidentifier ON mag_device_app(magidentifier);
CREATE INDEX mda_access_token ON mag_device_app(access_token);

CREATE TABLE mag_version (
  current_version char(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;
INSERT INTO mag_version (current_version) VALUES ('mag4.2.00');
--
-- Adding a table to support MAG OTP
--
CREATE TABLE mag_otp_records (
  USER_ID varchar(128) NOT NULL,
  OTP VARCHAR(64) NOT NULL,
  RETRY_COUNT TINYINT NOT NULL DEFAULT 0,
  EXPIRATION_TIME BIGINT NOT NULL DEFAULT 0,
  NEXT_ALLOWED_TIME BIGINT NOT NULL DEFAULT 0,
  CREATED BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE INDEX UIDX ON mag_otp_records(otp);

--
-- Adding a table to support MAG device metadata
--
CREATE TABLE mag_msso_device_metadata (
    magidentifier varchar(128) NOT NULL,
    name varchar(32) NOT NULL,
    value varchar(512) NOT NULL,
     /* The tag_value is prefixed with first 32 bytes in the index, smaller length can reduce index file size and improve insert performance. */
    PRIMARY KEY (magidentifier, name)
)
