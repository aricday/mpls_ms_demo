#!/bin/sh
## Try to load a Quickstart payloads via curl

hostname="msgw"
port=8443
username="admin"
password="password"
resource="quickstart/1.0/services"
timeout=30
template_dir="/opt/SecureSpan/Gateway/node/default/etc/bootstrap/quickstart"

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
    -tw|--template_dir)
    template_dir="$2"
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

check_url="http://${hostname}:${port}/${resource}"
check_cmd="curl -s -w %{http_code} '${check_url}' -o /dev/null"

## curl -k -4 -i -u 'admin:password' https://msgw.docker.local:9443/quickstart/1.0/services --data @files/msgw/quickstart/token_exchange.json
import_api()
{
	local file_name=$1
	#curl -H "Authorization: CALiveAPICreator e315ecb50cae07c799cfdc7a2567db4e:1" -H "Content-type: application/json" --data-binary @myExport.json -X POST http://localhost:8080/rest/abl/admin/v2/ProjectExport
	echo "com.ca.x-add-quickstart-template.sh: Importing file: '${file_name}'..."
	import_url="https://${hostname}:${port}/${resource}"
	import_cmd="curl -k -X POST -u $username:$password -H 'Content-Type: application/json' --data @$file_name '${import_url}'"
	echo "com.ca.x-add-quickstart-template.sh: '$import_cmd'"
	eval $import_cmd
	echo "com.ca.x-add-quickstart-template.sh: Finished importing"
}

## Main
# Run the scripts in the template directory
if [ ! -d $template_dir ]; then
echo "com.ca.x-add-quickstart-template.sh: $template_dir DNE" && exit 1
fi

for file_name in $template_dir/*.json
do
if [ -f $file_name ]
then
	import_api $file_name
else
        echo "com.ca.x-add-quickstart-template.sh: $file_name DNE"
fi
done
