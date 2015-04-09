#! /usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$DIR"/funcs.sh

sudo -p '[sudo] password for '"$(whoami)"' (For updating /etc/hosts): ' echo -n

echo 'Removing all socket-lb-* containers'
remove_containers

echo 'Removing socket-lb-* entries from /etc/hosts'
clear_hosts
