#!/bin/sh
set -e

# The script manages SSH tunnel. See README.md for details.

if [ "$#" -ne 6 ]; then
    echo "Error: Invalid input params, must be: \"REMOTE_PORT\" \"LOCAL_PORT\" \"SSH_USER\" \"SSH_HOST\" \"SSH_PORT\" \"SSH_KEY\". Exit."
    exit 1
fi

DIR=$(dirname $0)
LOG_DIR=$DIR/log

# Settings
REMOTE_PORT=$1
LOCAL_PORT=$2
SSH_USER=$3
SSH_HOST=$4
SSH_PORT=$5
SSH_KEY=$6

IP_LOG=$LOG_DIR/tun_ip.log

PID_CMD="$DIR/tun_pid.sh $REMOTE_PORT $LOCAL_PORT"
START_CMD="$DIR/tun_start.sh $REMOTE_PORT $LOCAL_PORT $SSH_USER $SSH_HOST $SSH_PORT $SSH_KEY"
STOP_CMD="$DIR/tun_stop.sh $REMOTE_PORT $LOCAL_PORT"

echo
echo [ $(date +%Y-%m-%d\ %H:%M:%S,%3N) ]

# Init
mkdir -p $LOG_DIR
if [ ! -f $IP_LOG ]; then
  echo "" > $IP_LOG
fi

# Start SSH tunnel if not exists
PID=$($PID_CMD)
if [ -n "$PID" ]; then
  echo "SSH tunnel is already created."
else
  $START_CMD &
  sleep 1
  PID=$($PID_CMD)
fi
echo "Pid: $PID"

echo "Checking for new public IP..."

# Get current IP
CURRENT_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "Current IP: $CURRENT_IP"

if [ -z "$CURRENT_IP" ]; then
  echo "Cannot get current IP. Exit."
  exit 1
fi

# Get last IP
LAST_IP=$(tail -n 1 $IP_LOG)
echo "Last IP:    $LAST_IP"

if [ "$CURRENT_IP" == "$LAST_IP" ]; then
  echo "IP is not changed. Exit."
  exit 0
fi

# Save current IP
echo $CURRENT_IP >> $IP_LOG

echo "Restarting SSH tunnel - started"
$STOP_CMD
$START_CMD &
echo "Restarting SSH tunnel - finished"
