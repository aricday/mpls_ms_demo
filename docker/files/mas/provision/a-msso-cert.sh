#!/bin/sh


# Check if the ca_msso private key already exists
keyExist=$(curl -k -i -u admin:password https://127.0.0.1:8443/restman/1.0/privateKeys?alias=ca_msso | grep "l7:Item")

# Create the private key if it doesn't exist.
if [[ ! -n "${keyExist}" ]]; then
    #### Begin private key install ####

    # Call RESTMAN to insert the private key
    # keyPostResult=$(curl -k -i -X POST -u admin:password -H "Content-Type: application/xml" -d @/opt/SecureSpan/Gateway/node/default/etc/bootstrap/bundle/after-start/ca_msso_key.xml https://127.0.0.1:8443/restman/1.0/privateKeys/00000000000000000000000000000002:ca_msso)
    keyPostResult=$(curl -k -i -X POST -u admin:password -H "Content-Type: application/xml" -d @/opt/docker/rc.d/base/ca_msso_key.xml https://127.0.0.1:8443/restman/1.0/privateKeys/00000000000000000000000000000002:ca_msso)

    case ${keyPostResult} in
    *"201 Created"*)
        echo "com.ca.trust-ca-msso-cert.sh : ca_msso private key created."
        ;;
    *)
        echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not create ca_msso private key.\n"
        echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${keyPostResult}\n"
        exit 1
        ;;
    esac
else
    echo "com.ca.trust-ca-msso-cert.sh : ca_msso private key already exists."
fi

# Check if Certificate already exists
certExist=$(curl -k -i -u admin:password https://127.0.0.1:8443/restman/1.0/trustedCertificates?name=ca_msso | grep "l7:Item")

# Create the certificate if not exists
if [[ ! -n "$certExist" ]]; then
    #### Begin install certificate ######

    # Grab the private key
    certValue=$(curl -k -s -u admin:password https://127.0.0.1:8443/restman/1.0/privateKeys?alias=ca_msso | grep l7:Encoded | sed -e 's/.*<l7:Encoded>\(.*\)<\/l7:Encoded>/\1/')

    # Detemplatize the bundle file
    MSSO_CERT=$(sed -e "s|ENCODED_CERT|${certValue}|g" /opt/docker/rc.d/base/ca_msso_cert.xml)

    # Call Restman to put the certificate.
    certPostResult=$(curl -k -i -X POST -u admin:password -H "Content-Type: application/xml" -d "${MSSO_CERT}" https://127.0.0.1:8443/restman/1.0/trustedCertificates)

    case ${certPostResult} in 
    *"201 Created"*)
        echo "com.ca.trust-ca-msso-cert.sh : ca_msso certificate is now trusted."
        ;;
    *)
        echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not trust ca_msso certificate.\n"
        echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${certPostResult}\n"
    esac

else
    echo "com.ca.trust-ca-msso-cert.sh : ca_msso certificate already trusted."
fi


# Create the FIP if not exists
if [[ ! -n "$fipExist" ]]; then
    #### Begin install FIP ######

    # Grab the certificate goid
    certIdValue=$(curl -k -s -u admin:password https://127.0.0.1:8443/restman/1.0/trustedCertificates?name=ca_msso | grep l7:Id | sed -e 's/.*<l7:Id>\(.*\)<\/l7:Id>/\1/')

    # Detemplatize the bundle file
    MSSO_FIP=$(sed -e "s|CERT_ID|${certIdValue}|g" /opt/docker/rc.d/base/ca_msso_fip.xml)

    # Call Restman to put the FIP.
    fipPostResult=$(curl -k -i -X POST -u admin:password -H "Content-Type: application/xml" -d "${MSSO_FIP}" https://127.0.0.1:8443/restman/1.0/identityProviders)

    case ${fipPostResult} in
    *"201 Created"*)
        echo "com.ca.trust-ca-msso-cert.sh : CA_MSSO Identity Provider is now created."
        ;;
    *)
        echo "com.ca.trust-ca-msso-cert.sh : ERROR: Could not create CA_MSSO Identity Provider.\n"
        echo "com.ca.trust-ca-msso-cert.sh : Response was: \n${fipPostResult}\n"
    esac

else
    echo "com.ca.trust-ca-msso-cert.sh : CA_MSSO Identity Provider already existed."
fi