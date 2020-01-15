#!/bin/bash

if [[ $# -ne 4 ]]; then
  echo 'You need 4 arguments : the Drone Github client ID, the Drone Github client secret, the Drone RPC secret and the server host (ie: the domain name)';
  exit;
fi

export DRONE_GITHUB_CLIENT_ID=$1
export DRONE_GITHUB_CLIENT_SECRET=$2
export DRONE_RPC_SECRET=$3
export DRONE_SERVER_HOST=$4

apt update
apt install docker.io

docker run \
  --volume=/var/lib/drone:/data \
  --env=DRONE_AGENTS_ENABLED=true \
  --env=DRONE_GITHUB_SERVER=https://github.com \
  --env=DRONE_GITHUB_CLIENT_ID=9eab8c94c3f036a84c08 \
  --env=DRONE_GITHUB_CLIENT_SECRET=c563c9231f89d65bc241f5516e0c543132f37b1d \
  --env=DRONE_RPC_SECRET=39fbddac5a893772fab8a770391e925c \
  --env=DRONE_SERVER_HOST=ci.ebacala.ovh \
  --env=DRONE_SERVER_PROTO=http \
  --publish=8081:80 \
  --publish=4433:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  drone/drone:1

  echo 'Drone CI started on port 8081'