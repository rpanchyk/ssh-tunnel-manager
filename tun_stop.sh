#!/bin/sh
set -e

# The script kills SSH tunnel process.

if [ "$#" -ne 2 ]; then
    echo "Error: Invalid input params, must be: \"REMOTE_PORT\" \"LOCAL_PORT\". Exit."
    exit 1
fi

# Settings
REMOTE_PORT=$1
LOCAL_PORT=$2

PID_CMD="$(dirname $0)/tun_pid.sh $REMOTE_PORT $LOCAL_PORT"

# Run
PID=$($PID_CMD)
if [ -z "$PID" ]; then
  echo "No SSH tunnel process running. Exit."
  exit 0
fi

for i in $PID; do
  echo "Killing SSH tunnel process ID: $i"
  kill -KILL $i
done
