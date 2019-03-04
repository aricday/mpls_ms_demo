#!/bin/sh
## Try to load an API via curl

[ -z "$MSGW_SSL_PUBLIC_CERT_B64" ] && echo "Need to set MSGW_SSL_PUBLIC_CERT_B64" && exit 1;

hostname="localhost"
port=8443
username="admin"
password="password"
fip_name="Gateway as a Client Identity Provider"
msgw_fqdn="msgw.docker.local"
msgw_cert="$(echo $MSGW_SSL_PUBLIC_CERT_B64)"
#ABSOLUTE_PATH="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
#current_dir="$(pwd -P)"
add_cmd="/opt/docker/rc.d/after-start/add-otk-user.sh"
#add_cmd="./add-otk-user.sh"

## Capture any command-line arguments
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -h|--hostname)
    hostname="$2"
    shift # past argument
    ;;
    -pt|--port)
    port="$2"
    shift # past argument
    ;;
    -u|--username)
    username="$2"
    shift # past argument
    ;;
    -pw|--password)
    password="$2"
    shift # past argument
    ;;
    -f|--fip_name)
    fip_name="$2"
    shift # past argument
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

import_cmd="$add_cmd $hostname:$port \"$username\" \"$password\" \"$fip_name\" \"$msgw_fqdn\" $msgw_cert"

#	source .custom.env; ./files/mas/provision/add-otk-user.sh localhost:8443 "admin" 'password' "Gateway as a Client Identity Provider" "msgw.docker.local" `echo $MSGW_SSL_PUBLIC_CERT_B64`
#	$add_cmd $hostname:$port "$username" "$password" "$fip_name" "$msgw_fqdn" "$msgw_cert"
## capture api_key and post data
import_user()
{
	#curl -H "Authorization: CALiveAPICreator e315ecb50cae07c799cfdc7a2567db4e:1" -H "Content-type: application/json" --data-binary @myExport.json -X POST http://localhost:8080/rest/abl/admin/v2/ProjectExport
	echo "Importing OTK: '${fip_name}'..."
	#echo $import_cmd
	eval $import_cmd
	echo "Finished importing"
}

## Main
echo $import_cmd
import_user
