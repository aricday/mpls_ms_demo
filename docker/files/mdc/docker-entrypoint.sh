#!/bin/ash
set -e

export MAS_HOSTNAME="${MAS_HOSTNAME:-mas}"
export MAS_PORT="${MAS_PORT:-8443}"
export MDC_HOSTNAME="${MDC_HOSTNAME:-$MAS_HOSTNAME}"
export MDC_PORT="${MDC_PORT:-8443}"

# Setup the api_config.json using the env hostname
sed -i"" 's/"/\\"/g' /usr/share/nginx/html/api_config.json
eval "echo \"$(cat /usr/share/nginx/html/api_config.json)\"" > /usr/share/nginx/html/api_config.json

# Generate an SSL Certificate using the env hostname
#sed 's/\[ v3_ca \]/\[ v3_ca \]\'$'\nsubjectAltName=DNS:'"${MDC_HOSTNAME}"'/' /etc/ssl/openssl.cnf > custom_openssl.cnf
#openssl req -x509 \
#-nodes \
#-days 365 \
#-newkey rsa:2048 \
#-subj "/C=CA/ST=BC/L=Vancouver/O=CA Technologies/CN=${MDC_HOSTNAME}" \
#-config custom_openssl.cnf \
#-keyout /etc/nginx/ssl/dev-console.key \
#-out /etc/nginx/ssl/dev-console.crt

exec "$@"
