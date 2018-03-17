#!/bin/sh
set -e

# The script starts SSH tunnel between local and remote machine.

if [ "$#" -ne 6 ]; then
    echo "Error: Invalid input params, must be: \"REMOTE_PORT\" \"LOCAL_PORT\" \"SSH_USER\" \"SSH_HOST\" \"SSH_PORT\" \"SSH_KEY\". Exit."
    exit 1
fi

# Settings
REMOTE_PORT=$1
LOCAL_PORT=$2
SSH_USER=$3
SSH_HOST=$4
SSH_PORT=$5
SSH_KEY=$6

# Run
echo "Creating SSH tunnel..."
while true
do
  ssh -R 0.0.0.0:$REMOTE_PORT:localhost:$LOCAL_PORT $SSH_USER@$SSH_HOST -p$SSH_PORT \
    -i $SSH_KEY \
    -o ServerAliveInterval=60 \
    -o ExitOnForwardFailure=yes \
    -N -C
  echo "Recreating SSH tunnel..."
  sleep 5
done
