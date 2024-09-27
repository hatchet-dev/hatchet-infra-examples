#!/bin/bash
# This scripts generates CloudKMS keys for the given environment.

# gcp project id is required
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "Please set GCP_PROJECT_ID variable"
    exit 1
fi

# env name is required
if [ -z "$ENV_NAME" ]; then
    echo "Please set ENV_NAME variable"
    exit 1
fi

# credentials path is required
if [ -z "$CREDENTIALS_PATH" ]; then
    echo "Please set CREDENTIALS_PATH variable"
    exit 1
fi

KEYS_DIR=./$ENV_NAME
mkdir -p $KEYS_DIR

hatchet-admin keyset create-cloudkms-jwt \
    --key-dir $KEYS_DIR \
    --credentials $CREDENTIALS_PATH \
    --key-uri gcp-kms://projects/$GCP_PROJECT_ID/locations/global/keyRings/$ENV_NAME/cryptoKeys/$ENV_NAME