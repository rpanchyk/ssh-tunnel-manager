#!/bin/sh
set -e

# The script determines PID of SSH tunnel.

if [ "$#" -ne 2 ]; then
    echo "Error: Invalid input params, must be: \"REMOTE_PORT\" \"LOCAL_PORT\". Exit."
    exit 1
fi

# Settings
REMOTE_PORT=$1
LOCAL_PORT=$2

SSH_CMD="ssh -R 0.0.0.0:$REMOTE_PORT:localhost:$LOCAL_PORT"

# Run
echo $(ps aux | grep -i "$SSH_CMD" | grep -v grep | awk '{print $2}')
