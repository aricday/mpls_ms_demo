#
#  Copyright (c) 2016 CA. All rights reserved.
#
#  This software may be modified and distributed under the terms
#  of the MIT license. See the LICENSE file for details.
#
# This creates the user in mysql and grant it permissions
CREATE DATABASE IF NOT EXISTS ssg DEFAULT CHARSET=utf8;
GRANT ALL PRIVILEGES ON *.* TO 'db_admin'@'%' identified by 'UTWtziFHF0xgng==';
FLUSH PRIVILEGES;