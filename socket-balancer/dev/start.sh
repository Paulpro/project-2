#! /usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$DIR"/funcs.sh

sudo -p '[sudo] password for '"$(whoami)"' (For updating /etc/hosts): ' echo -n

source "$DIR"/stop.sh

echo 'Starting Redis Container'
start_redis

echo 'Starting servers'
start_servers 3

echo 'Appending new entries to hosts file'
append_hosts
