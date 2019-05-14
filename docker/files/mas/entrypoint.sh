#!/bin/sh

# Maintained by aric.day@broadcom.com

########################################################################################################################
# Constants
########################################################################################################################

DEFAULT_SSG_JVM_HEAP="2g"
DEFAULT_DERBY_ARGS="-Dderby.locks.deadlockTimeout=45 -Dderby.storage.pageCacheSize=7500 -Dderby.language.sequence.preallocator=2500 -Dderby.language.statementCacheSize=150 -Dderby.storage.pageSize=32768 -Dcom.l7tech.server.derbyPrefix=memory:"

# Default number of seconds that this script will wait for the Gateway database to be available.
DEFAULT_SSG_DATABASE_WAIT_TIMEOUT="300"

########################################################################################################################
# Functions
########################################################################################################################

error() {
	# Send errors to stderr in case these get handled differently by the container PaaS on which this runs
	echo "ERROR - ${1}" 1>&2
	exit 1
}

# While this looks redundant, it allows derived image to override where these messages go.
info() {
	echo "${1}"
}

generateRandomHexString() {
	BYTES_TO_GEN="$1"
	[ "${BYTES_TO_GEN}" == "" ] && error "In generateRandomHexString(): need to be given the number of bytes to generate."
	(echo "${BYTES_TO_GEN}" | grep '^[::digit:]]\+$' &> /dev/null) && error "In generateRandomHexString(): need to be given a number."
	
	dd if=/dev/urandom bs=1 count=${BYTES_TO_GEN} status=none | od -vt x1 -An | tr -d ' \n'
}

checkEnvVars() {
	# When checking certain env vars below, rather than using grep we used tr to remove illegal characters and checked for equality
	# This was done to avoid having to use a heavily escaped regular expression
	
	# Check the heap size for the Gateway's JVM
	if [ -n "${SSG_JVM_HEAP}" ]; then
		if (! echo "${SSG_JVM_HEAP}" | grep '^[[:digit:]]\+[kKmMgG]$' &> /dev/null); then
			error "Invalid value provide for SSG_JVM_HEAP. It must be digits followed by one of the characters k, K, m, M, g, or G."
		fi
	fi

	# Check the Gateway admin settings if provided
	if [ -n "${SSG_ADMIN_USERNAME}" ]; then
		[ -n "$(echo ${SSG_ADMIN_USERNAME} | tr -d '[:alnum:]!@.=\-_^+;:#,%')" ] && error 'SSG_ADMIN_USERNAME may only contains characters from the set "!@.=-_^+;:#,%" as well as alphanumeric ASCII characters.'
	fi
	if [ -n "${SSG_ADMIN_PASSWORD}" ]; then
		[ -n "$(echo ${SSG_ADMIN_PASSWORD} | tr -d '[:alnum:]!@.=\-_^+;:#,%')" ] && error 'SSG_ADMIN_PASSWORD may only contains characters from the set "!@.=-_^+;:#,%" as well as alphanumeric ASCII characters.'
	fi

	# Check database related env vars
	if [ "${SSG_DATABASE_TYPE}" = "mysql" ]; then
		[ -z "${SSG_DATABASE_USER}" ] && error "SSG_DATABASE_USER environment variable not declared."
		[ -z "${SSG_DATABASE_PASSWORD}" ] && error "SSG_DATABASE_PASSWORD environment variable not declared."
		[ -z "${SSG_DATABASE_WAIT_TIMEOUT}" ] && info "SSG_DATABASE_WAIT_TIMEOUT not set."
		[ -n "$(echo ${SSG_DATABASE_USER} | tr -d '[:alnum:]')" ] && error 'SSG_DATABASE_USER may only contain alphanumeric ASCII characters.'
		[ -n "$(echo ${SSG_DATABASE_PASSWORD} | tr -d '[:alnum:]')" ] && error 'SSG_DATABASE_PASSWORD may only contain alphanumeric ASCII characters.'
		(echo "${SSG_DATABASE_WAIT_TIMEOUT}" | grep '^[[:digit:]]*$' &>/dev/null) || error "Value provided for SSG_DATABASE_WAIT_TIMEOUT is not an integer"
		( echo "${SSG_DATABASE_JDBC_URL}" | grep -F 'characterEncoding=UTF8' &> /dev/null ) || error "Value provided for SSG_DATABASE_JDBC_URL does not set the characterEncoding to UTF8"
		( echo "${SSG_DATABASE_JDBC_URL}" | grep -F 'characterSetResults=UTF8' &> /dev/null ) || error "Value provided for SSG_DATABASE_JDBC_URL does not set the characterSetResults to UTF8"
	fi

	# Check Gateway cluster settings
	# tests for compliance with hostnames as defined in RFC 952 and section 2.1 of RFC 1123
	[ -z "${SSG_CLUSTER_HOST}" ] && error "SSG_CLUSTER_HOST environment variable not set. This is required when the SSG_DATABASE_JDBC_URL env var is used."
	(echo "${SSG_CLUSTER_HOST}" | grep -E '^(([[:alnum:]]|[[:alnum:]][[:alnum:]\-]*[[:alnum:]])\.)*([[:alnum:]]|[[:alnum:]][[:alnum:]\-]*[[:alnum:]])$' &>/dev/null) || error "SSG_CLUSTER_HOST doesn't look like a hostname or FQDN"
	[ "${SSG_DATABASE_TYPE}" = "mysql" ] && [ -z "${SSG_CLUSTER_PASSWORD}" ] && error "SSG_CLUSTER_PASSWORD must be set when using a MySQL database."
	if [ -n "${SSG_CLUSTER_PASSWORD}" ]; then
		[ -n "$(echo ${SSG_CLUSTER_PASSWORD} | tr -d '[:alnum:]!@.=\-_^+;:#,%')" ] && error 'SSG_CLUSTER_PASSWORD may only contains characters from the set "!@.=-_^+;:#,%" as well as alphanumeric ASCII characters.'
	fi
}

setEnvVars() {

	# Create database settings
	if [ -z "${SSG_DATABASE_JDBC_URL}" ]; then
		info "Using Derby database"
		export SSG_DATABASE_TYPE="derby"
		DERBY_ARGS="${DEFAULT_DERBY_ARGS}"
	else
		info "Using MySQL database"
		export SSG_DATABASE_TYPE="mysql"
		# Set to empty when using mysql
		DERBY_ARGS=""
		# How long to wait for the MySQL server to be available (in seconds)
		SSG_DATABASE_WAIT_TIMEOUT="${SSG_DATABASE_WAIT_TIMEOUT:-${DEFAULT_SSG_DATABASE_WAIT_TIMEOUT}}"
		info "SSG_DATABASE_WAIT_TIMEOUT set to ${SSG_DATABASE_WAIT_TIMEOUT} seconds."

		# set UTF8 related settings if the user doesn't provide them
		( echo "${SSG_DATABASE_JDBC_URL}" | grep '?' &> /dev/null ) || export SSG_DATABASE_JDBC_URL="${SSG_DATABASE_JDBC_URL}?characterEncoding=UTF8&characterSetResults=UTF8"
		( echo "${SSG_DATABASE_JDBC_URL}" | grep '?$' &> /dev/null ) && export SSG_DATABASE_JDBC_URL="${SSG_DATABASE_JDBC_URL}characterEncoding=UTF8&characterSetResults=UTF8"
		( echo "${SSG_DATABASE_JDBC_URL}" | grep 'characterEncoding' &> /dev/null ) || export SSG_DATABASE_JDBC_URL="${SSG_DATABASE_JDBC_URL}&characterEncoding=UTF8"
		( echo "${SSG_DATABASE_JDBC_URL}" | grep 'characterSetResults' &> /dev/null ) || export SSG_DATABASE_JDBC_URL="${SSG_DATABASE_JDBC_URL}&characterSetResults=UTF8"
	fi

	SSG_JVM_HEAP="${SSG_JVM_HEAP:-${DEFAULT_SSG_JVM_HEAP}}"
	info "SSG_JVM_HEAP will be ${SSG_JVM_HEAP}"

	# If the user doesn't provide a value and is using Derby
	# set the cluster hostname to the hostname of the container, not the host on which it runs
	if [ "${SSG_DATABASE_TYPE}" = "derby" ]; then
		SSG_CLUSTER_HOST="${SSG_CLUSTER_HOST:-$(hostname)}"
	fi
	info "SSG_CLUSTER_HOST will be ${SSG_CLUSTER_HOST}"
}

createAndUpdateMySQLDatabase() {
	ADMIN_CONFIGURED="true"

	if [ "${SSG_DATABASE_TYPE}" == "mysql" ]; then
		LIQUIBASE_JDBC_URL="$(echo "${SSG_DATABASE_JDBC_URL}" | sed -E 's|(.*)\?.*|\1|g')"
		# these settings are just used for the code below (waiting for the database to come up and the Liquibase calls)
		LIQUIBASE_JDBC_URL="${LIQUIBASE_JDBC_URL}?autoReconnect=false&useSSL=false&characterEncoding=UTF8&characterSetResults=UTF8&socketTimeout=1000&connectTimeout=1000&createDatabaseIfNotExist=true"

		LIQUIBASE_JAR=`ls ${GATEWAY_DIR}/runtime/lib/liquibase-*jar`
		MYSQL_CONNECTOR_JAR=`ls ${GATEWAY_DIR}/runtime/lib/mysql-connector-java-*jar`
		LIQUIBASE="java -jar ${LIQUIBASE_JAR} --driver=com.mysql.jdbc.Driver \
			--classpath=${MYSQL_CONNECTOR_JAR} \
			--changeLogFile=${GATEWAY_DIR}/config/etc/db/ssg.xml \
			--url=${LIQUIBASE_JDBC_URL} \
			--username=${SSG_DATABASE_USER} \
			--password=${SSG_DATABASE_PASSWORD}"

		# Wait until any of the MySQL servers are available
		info "Waiting for one of the databases to come up..."
		TIMEOUT_TIMESTAMP=$(date --date="${SSG_DATABASE_WAIT_TIMEOUT} sec" '+%s')
		until $LIQUIBASE listLocks &>/dev/null; do
			CURRENT_TIMESTAMP=$(date '+%s')
			if [ "${CURRENT_TIMESTAMP}" -gt "${TIMEOUT_TIMESTAMP}" ]; then
				error "Timed out while waiting for database to come up"
			fi
			/bin/sleep 1
		done

		### Determine if admin user needs to be created ###
		UNRUN_CHANGESETS=$($LIQUIBASE status --verbose)
		for CHANGESET in ${UNRUN_CHANGESETS}; do
		    # look for changeset id "1408665436018-7", which adds the admin user to the internal_user table
		    if [[ $CHANGESET == *"ssg-data.xml::1408665436018-7::gateway" ]]; then
		        ADMIN_CONFIGURED="false"
		        break
		    fi
		done

		### Do update ###
		$LIQUIBASE update
		if [ "$?" != "0" ]; then
			error "Failed to create or update the Gateway's database"
		fi
	else
		ADMIN_CONFIGURED="false"
	fi
}


acceptLicense(){
	[ "${ACCEPT_LICENSE}" == "true" ] || error "License not accepted (environment variable ACCEPT_LICENSE=${ACCEPT_LICENSE})"
}

configureAdminUser() {
	### Ensure the admin user is configured ###
	if [ "${ADMIN_CONFIGURED}" == "false" ]; then
		# Disable the built-in admin user
        DEF_PASS=$(generateRandomHexString 64)
        SSG_ADMIN_PASSWORD="${SSG_ADMIN_PASSWORD:-${DEF_PASS}}"

        DEF_ADMIN_USERNAME=$(generateRandomHexString 64)
        SSG_ADMIN_USERNAME="${SSG_ADMIN_USERNAME:-${DEF_ADMIN_USERNAME}}"

        UPDATE_ADMIN_TEMPLATE=$(sed -e "s~SSG_ADMIN_USERNAME~${SSG_ADMIN_USERNAME}~g" -e "s~SSG_ADMIN_PASSWORD~${SSG_ADMIN_PASSWORD}~g" /opt/docker/rc.d/base/update_admin_user.xml)
        echo "${UPDATE_ADMIN_TEMPLATE}" > ${GATEWAY_DIR}/node/default/etc/bootstrap/bundle/001_update_admin_user.xml.req.bundle
	fi
}
#Added to create JDBC/Cassandra connection for OTK installation
prepareOTK(){
	OTK_JDBC_CONNECTION=$(sed -e "s~OTK_DATABASE_USER~${OTK_DATABASE_USER}~g" -e "s~OTK_DATABASE_PASSWORD~${OTK_DATABASE_PASSWORD}~g" -e "s~OTK_DATABASE_JDBC_URL~${OTK_DATABASE_JDBC_URL}~g" /opt/docker/rc.d/base/otk-jdbc-connection.xml)
	echo "${OTK_JDBC_CONNECTION}" > ${GATEWAY_DIR}/node/default/etc/bootstrap/bundle/otk-jdbc-connection.bundle
	
	OTK_CASSANDRA_CONNECTION=$(sed -e "s~OTK_CASSANDRA_KEYSPACE~${OTK_CASSANDRA_KEYSPACE}~g" -e "s~OTK_CASSANDRA_PORT~${OTK_CASSANDRA_PORT}~g" -e "s~OTK_CASSANDRA_CONTACTPOINT~${OTK_CASSANDRA_CONTACTPOINT}~g" /opt/docker/rc.d/base/otk-cassandra-connection.xml)
	echo "${OTK_CASSANDRA_CONNECTION}" > ${GATEWAY_DIR}/node/default/etc/bootstrap/bundle/otk-cassandra-connection.bundle		
}

#Added to create JDBC connection for MAG installation
prepareMAG(){
	MAG_JDBC_CONNECTION=$(sed -e "s~MAG_DATABASE_USER~${MAG_DATABASE_USER}~g" -e "s~MAG_DATABASE_PASSWORD~${MAG_DATABASE_PASSWORD}~g" -e "s~MAG_DATABASE_JDBC_URL~${MAG_DATABASE_JDBC_URL}~g" /opt/docker/rc.d/base/mag-jdbc-connection.xml)
	echo "${MAG_JDBC_CONNECTION}" > ${GATEWAY_DIR}/node/default/etc/bootstrap/bundle/mag-jdbc-connection.bundle	
}

updateClusterHost() {

	UPDATE_CLUSTER_HOSTNAME=$(sed -e "s~CLUSTER_HOST_VALUE~${SSG_CLUSTER_HOST}~g" /opt/docker/rc.d/base/update_cluster_host.xml)
	echo "${UPDATE_CLUSTER_HOSTNAME}" > ${GATEWAY_DIR}/node/default/etc/bootstrap/bundle/010_update_cluster_host.xml.req.bundle
}

runGatewayPreBootScripts() {
	# Let derived images tweak stuff before Gateway starts by dropping scripts into /opt/docker/rc.d/
	for i in /opt/docker/rc.d/*.sh; do
		if [ -r "${i}" ]; then
			info "Running script ${i}"
			/bin/sh ${i}
			if [ $? -ne 0 ]; then
				error "Failed executing the script: ${i}"
			fi
		fi
	done
	unset i
}

startGateway() {
	info "Starting gateway in background"
	touch /opt/SecureSpan/Gateway/node/default/var/preboot
	if test -f /opt/SecureSpan/Gateway/node/default/var/started; then 
		rm -f /opt/SecureSpan/Gateway/node/default/var/started
	fi
	cd "${GATEWAY_DIR}/runtime"
	eval java \
		-Xms${SSG_JVM_HEAP} \
		-Xmx${SSG_JVM_HEAP} \
		-XX:+TieredCompilation \
		-Dcom.l7tech.disklessConfig=true \
		-Dcom.l7tech.server.sm.noSecurityManager=true \
		-Dcom.l7tech.server.log.console=true \
		-Dcom.l7tech.server.log.console.extraCats="AUDIT,LOG" \
		-Djava.net.preferIPv4Stack=true \
		-Djava.security.egd=file:/dev/./urandom \
		-Dcom.l7tech.server.defaultClusterHostname="${SSG_CLUSTER_HOST}" \
		-Dcom.l7tech.gateway.remoting.connectionTimeout=500 \
		-Djava.ext.dirs="${JAVA_HOME}/lib/ext:${GATEWAY_DIR}/runtime/lib/ext" \
		-Dcom.l7tech.server.components=uddi \
		-Dcom.l7tech.bootstrap.env.sslkey.enable=true \
		-Dcom.l7tech.bootstrap.license.require=true \
		${DERBY_ARGS} \
		${EXTRA_JAVA_ARGS} \
		-jar Gateway.jar "$@" start >> /tmp/console.log 2>&1 "&"
		
		# wait until Gateway is up and running, didn't handle the situation where the gateway failed to start.
		until test -f /opt/SecureSpan/Gateway/node/default/var/started; do
			 >&2 echo "Gateway not started yet, keep waiting...";   sleep 5;
		done
		>&2 echo "Gateway started. Continuing."; rm -f /opt/SecureSpan/Gateway/node/default/var/started;
}

#Added to install OTK and MAG
installOTK(){
	# Determine if OTK already installed
	token_endpoint_missing=$(curl -u $SSG_ADMIN_USERNAME:$SSG_ADMIN_PASSWORD --insecure -X GET -k -s -D - https://localhost:8443/auth/oauth/v2/token | grep "Service Not Found" | wc -l)
	if [ $token_endpoint_missing == "1" ]; then
		# OTK haven't installed yet, proceed with installation.
		echo "Installing OTK in background..."
		
		#call the RESTMAN API to install OTK
		curl -u $SSG_ADMIN_USERNAME:$SSG_ADMIN_PASSWORD --insecure -X POST -k -H 'Content-Type: multipart/form-data' --form entityIdReplace=4432207d16a1b505e8a6ed59993eaa24::175ace8f404dd47c8cefe0a762271542 --form entityIdReplace=c2e0825b2f52dc7819cd6e68893df156::8e7af8f5fe78af7719574812da0b3c8e --form "file=@//root/OTK_Installers/OAuthSolutionKit-4.2.00-3367.sskar" -s -D - https://localhost:8443/restman/1.0/solutionKitManagers
		echo "OTK installed successfully. Continuing."

		echo "Installing MAG in background..."
		#call the RESTMAN API to install MAG
		curl -u $SSG_ADMIN_USERNAME:$SSG_ADMIN_PASSWORD --insecure -X POST -k -H 'Content-Type: multipart/form-data' --form entityIdReplace=cbeedf1e2650e80f4d660a7fdb8fea13::175ace8f404dd47c8cefe0a762271543 --form entityIdReplace=5a97f3bdcbc049ccaebbe9ccb8379ccb::8e7af8f5fe78af7719574812da0b3c8e --form "file=@//root/MAG_Installers/MAGSolutionKit-4.2.00-2716.sskar" -s -D - https://localhost:8443/restman/1.0/solutionKitManagers
		echo "MAG installed successfully. Continuing."

		echo "Installing MAS-Identity in background..."
		#call the RESTMAN API to install MAG
		curl -u $SSG_ADMIN_USERNAME:$SSG_ADMIN_PASSWORD --insecure -X POST -k -H 'Content-Type: multipart/form-data' --form entityIdReplace=3fdf42538190460396f3e703d31b22d9::0000000000000000fffffffffffffffe --form entityIdReplace=7a3b078427ed19baaac98cf92fef120b::8e7af8f5fe78af7719574812da0b3c8e --form entityIdReplace=3772b9a8f897e0a2e0b5bae228f70a6e::0000000000000000fffffffffffffffe --form entityIdReplace=a6adb5912420041ef353d70fd39cdab0::175ace8f404dd47c8cefe0a762271543 --form ScimSecuritySelection=TLSOAuthToken --form 'file=@//root/MAG_Installers/MAS-Identity-4.2.00-b620.sskar' -s -D - https://localhost:8443/restman/1.0/solutionKitManagers
		echo "MAS-Identity installed successfully. Continuing."

		echo "Installing MAS-Messsaging in background..."
		#call the RESTMAN API to install MAG
		curl -u $SSG_ADMIN_USERNAME:$SSG_ADMIN_PASSWORD --insecure -X POST -k -H 'Content-Type: multipart/form-data' --form entityIdReplace=a6adb5912420041ef353d70fd39cdab0::175ace8f404dd47c8cefe0a762271543 --form MasConfigurationBrokerHost=mqtt.vagrant.local --form MasConfigurationBrokerPort=1883 --form MasMessagingSecuritySelection=TCPNoAuth --form 'file=@//root/MAG_Installers/MAS-Messaging-4.2.00-b885.sskar' -s -D - https://localhost:8443/restman/1.0/solutionKitManagers
		echo "MAS-Messaging installed successfully. Continuing."

		echo "Installing MDC solution kit..."
		curl -u $SSG_ADMIN_USERNAME:$SSG_ADMIN_PASSWORD --insecure -X POST -k -H 'Content-Type: multipart/form-data' --form entityIdReplace=8bc013b1238e366ee30841839616078f::175ace8f404dd47c8cefe0a762271542 --form "file=@//root/MAG_Installers/MobileDeveloperConsole-1.1.00-9.sskar" -s -D - https://localhost:8443/restman/1.0/solutionKitManagers
		echo "MDC installed successfully. Continuing."

		echo "Shutting down the gateway to perform required restart post OTK&MAG installation..."
		ssg_pid=$(grep java /proc/*/status | awk -F'/' '{print $3}')
		kill $ssg_pid		
		
		echo "Restarting the gateway..."

			cd "${GATEWAY_DIR}/runtime"
		eval java \
			-Xms${SSG_JVM_HEAP} \
			-Xmx${SSG_JVM_HEAP} \
			-XX:+TieredCompilation \
			-Dcom.l7tech.disklessConfig=true \
			-Dcom.l7tech.server.sm.noSecurityManager=true \
			-Dcom.l7tech.server.log.console=true \
			-Dcom.l7tech.server.log.console.extraCats="AUDIT,LOG" \
			-Djava.net.preferIPv4Stack=true \
			-Djava.security.egd=file:/dev/./urandom \
			-Dcom.l7tech.server.defaultClusterHostname="${SSG_CLUSTER_HOST}" \
			-Dcom.l7tech.gateway.remoting.connectionTimeout=500 \
			-Djava.ext.dirs="${JAVA_HOME}/lib/ext:${GATEWAY_DIR}/runtime/lib/ext" \
			-Dcom.l7tech.server.components=uddi \
			-Dcom.l7tech.bootstrap.env.sslkey.enable=true \
			-Dcom.l7tech.bootstrap.license.require=true \
			${DERBY_ARGS} \
			${EXTRA_JAVA_ARGS} \
			-jar Gateway.jar "$@" start >> /tmp/console.log 2>&1 "&"
		
			# wait until Gateway is up and running, didn't handle the situation where the gateway failed to start.
			until test -f /opt/SecureSpan/Gateway/node/default/var/started; do
				 >&2 echo "Gateway not started yet, keep waiting...";   sleep 5;
			done
			>&2 echo "Gateway 9.4 provisioned successfully with OTK 4.3.1. Done"		
	else
		echo "OTK already installed. Done"
	fi
}

runGatewayPostBootScripts() {
	# Let derived images tweak stuff before Gateway starts by dropping scripts into /opt/docker/rc.d/
	for i in /opt/docker/rc.d/after-start/*.sh; do
		if [ -r "${i}" ]; then
			info "Running script ${i}"
			/bin/sh ${i}
			if [ $? -ne 0 ]; then
				error "Failed executing the script: ${i}"
			fi
		fi
	done
	unset i
}

displayGatewayLog(){
	#display gateway console logs and keep container running
	tail -f /tmp/console.log
}

########################################################################################################################
# Main
########################################################################################################################

acceptLicense
setEnvVars
checkEnvVars
createAndUpdateMySQLDatabase
configureAdminUser
prepareOTK
prepareMAG
updateClusterHost
runGatewayPreBootScripts
startGateway
installOTK
runGatewayPostBootScripts
displayGatewayLog

