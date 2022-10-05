#!/bin/bash


echo "Blob Extract"

HOSTNAME=''
IMAGE=''
IMAGE_TAG=''
PORT=''

MANIFEST='http://$HOSTNAME:$PORT/v2/$IMAGE/maifests/$IMAGE_TAG'
BLOB_URL='http://$HOSTNAME:$PORT/v2/$IMAGE/blobs/'
BLOBS=$(curl $MANIFEST | jq '.fsLayers' | jq -c '.[]' | jq -r '.blobSum')
i=1
for blob in $BLOBS:
do
    curl $BLOB_URL/blob -s --output $i.tar
    ((i=i+1))
done
