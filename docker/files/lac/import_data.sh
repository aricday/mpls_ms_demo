#!/bin/bash
## Try to load an API via curl

hostname="localhost"
port=8080
username="admin"
password="Password1"
resource="rest/default/data/v1/beers"
import_file="BeerData.json"
import_resource="rest/abl/admin/v2/ProjectExport"
timeout=30

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
    -t|--timeout)
    timeout="$2"
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
auth_resource="rest/abl/admin/v2/@authentication"

## generate the post data with variables
generate_auth_post_data()
{
  cat <<EOF
{
  "username": "$username",
  "password": "$password"
}
EOF
}

## capture api_key
get_api_key()
{
	echo "Generating auth token..."
	#auth_cmd="curl -X POST -s -H 'Content-Type: application/json' -d '$(generate_auth_post_data)' 'http://${hostname}:${port}/${auth_resource}' 2>&1"
	auth_url="http://${hostname}:${port}/${auth_resource}"
	auth_cmd="curl -X POST -s -H 'Content-Type: application/json' -d '$(generate_auth_post_data)' '${auth_url}' 2>&1 | grep 'apikey' | awk '{print \$2}' | sed -e 's/\"//g' -e 's/,//'"
	#echo $auth_cmd
	api_key=$(eval $auth_cmd)
	echo "api_key: '${api_key}'"
}
## capture api_key and post data
import_api()
{
	#curl -H "Authorization: CALiveAPICreator e315ecb50cae07c799cfdc7a2567db4e:1" -H "Content-type: application/json" --data-binary @myExport.json -X POST http://localhost:8080/rest/abl/admin/v2/ProjectExport
	echo "Importing file: '${import_file}'..."
	import_url="http://${hostname}:${port}/${import_resource}"
	import_cmd="curl -i -X POST -s -H 'Authorization: CALiveAPICreator $api_key:1' -H 'Content-Type: application/json' --data-binary @$import_file '${import_url}'"
	#echo $import_cmd
	eval $import_cmd
	echo "Finished importing"
}

## Main
echo $check_cmd
end=$((SECONDS+$timeout))
current=0
while [ $SECONDS -lt $end ]; do
	check_code=$(eval $check_cmd)
	echo "http_code: $check_code"
	if [[ (($check_code == 404)) ]]; then
		echo "Need to import since '${check_url}' DNE..."
		get_api_key
		import_api
		break
	elif [[ (($check_code == 401)) ]]; then
		echo "Unauthorized. Let's try to import anyway"
		get_api_key
		import_api
		break
	elif [[ (($check_code == 500)) ]]; then
		echo "Weird (different from v4.0) Response. Aric's try to import anyway"
		get_api_key
		import_api
		break
	elif [[ (($check_code == 000)) ]]; then
		echo "'${check_url}' is not available"
	else
		echo "'${check_url}' already exists"
		break
	fi
	echo "Sleeping: $current..."
	current=$(($current+1))
	sleep 1
done
