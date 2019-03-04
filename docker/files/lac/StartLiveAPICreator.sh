#!/bin/sh
#
# Copy the databases to their location if they don't already exist.

if [ -z "$RDS_HOSTNAME" ]
then
    if [ ! -e /usr/local/CALiveAPICreator/databases ]
    then
        echo "Databases not found -- initializing with default"
        mkdir -p /usr/local/CALiveAPICreator/databases
        cd /usr/local/CALiveAPICreator/databases
        unzip -q /usr/local/tomcat/AllDerbyDatabases.zip
    else
        echo "/usr/local/CALiveAPICreator/databases was found"
    fi
else
    echo "Using MySQL database from environment variables"
fi

export LAC_DEFAULT_LICENSE_FILE=/usr/local/tomcat/bin/lac_license.json

cd /usr/local/tomcat/bin
sleep 5
./import_data.sh 2>&1 &

# if [ ! -z "$RDS_HOSTNAME" ] && [ ! -z "$RDS_PORT" ]
# then
#   START_TIMEOUT=60
#   if [ ! -z "$LAC_START_DB_TIMEOUT" ]
#   then
#     START_TIMEOUT=$LAC_START_DB_TIMEOUT
#   fi
#   echo CA Live API Creator is checking connectivity to the database on host $RDS_HOSTNAME...
#   ./wait-for-it.sh --quiet --host=$RDS_HOSTNAME --port=$RDS_PORT --strict --timeout=$START_TIMEOUT -- ./catalina.sh run
#   if [ ! $? -eq 0 ]
#   then
#     echo Timeout \($START_TIMEOUT seconds\) trying to connect to the database on server $RDS_HOSTNAME, port $RDS_PORT.
#     echo CA Live API Creator was unable to start because it cannot connect to its admin database.
#     exit 100
#   fi
# fi

./catalina.sh run
