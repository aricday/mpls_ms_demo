###############################################################################
##  Name:   Dockerfile
##  Date:   2019-02-26
##  Developer:  Aric Day
##  Email:  aric.day@broadcom.com
##  Purpose:   This Dockerfile contains an example process
################################################################################

# Using official python runtime base apline image
FROM python:3.6-alpine

# Set the file maintainer (your name - the file's author)
MAINTAINER Day, Aric <aric.day@broadcom.com>

# Set the application directory
WORKDIR /app

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies for Python are installed later
RUN apk add --no-cache ca-certificates

# Install dependencies for Cryptography
RUN apk add --no-cache \
	build-base \
	libffi-dev \
	musl-dev \
	openssl-dev \
	python-dev

# Install our requirements.txt
ADD requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Cleanup
RUN rm -rf /var/cache/apk/*

# Explicitly copy our config, lib, and code from the current folder to /app inside the container
ADD config /app/config
ADD api /app/api

## TODO change certificate to Vault directory
#RUN mkdir /app/config/certs

EXPOSE 8000

ENTRYPOINT ["python", "api/main.py"]
# Define our command to be run when launching the container
#CMD ["--help"]