#! /usr/bin/env bash

function get_dir ( ) {
    echo "$( get_dev_dir )"/..
}

function get_dev_dir ( ) {
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function stop_containers ( ) {
    docker ps -a | grep -oE 'socket-lb-\S*' | xargs docker stop
}

function resume_containers ( ) {
    docker ps -a | grep -oE 'socket-lb-redis\S*' | xargs docker start
    docker ps -a | grep -oE 'socket-lb-server-.*)\S*' | xargs docker start
    docker start socket-lb-server
}

function remove_containers ( ) {
  docker ps -a | grep -oE 'socket-lb-\S*' | xargs -r docker rm -f
}

function start_redis ( ) {
    docker run -d --name=socket-lb-redis redis > /dev/null
}

function start_server ( ) {
    docker run -d \
      --name=socket-lb-server-"$1" \
      -h socket-lb-server-"$1" \
      --link socket-lb-redis:socket-lb-redis \
      -v "$(get_dir)":/data \
      -w /data/src \
      node \
      bash -c 'npm install && `npm bin`/forever -w server/server.js' \
    > /dev/null
}

function start_servers ( ) {
    for ((i = 1; i <= "$1"; i++)); do
        start_server "$i"
    done

    start_load_balancer socket-lb-server
}


function start_load_balancer ( ) {

    nodes="$( docker ps | grep -Eo "$1"-'\S*' )"    
    link_nodes="$( echo "$nodes" | sed 's/^.*$/--link \0:\0/' | tr '\n' '\t')"

    docker run -d \
      --name=socket-lb-server \
      -h socket-lb-server \
      --link socket-lb-redis:socket-lb-redis \
      -v "$(get_dir)":/data \
      -w /data/src \
      $link_nodes \
      node \
      bash -c 'npm install && `npm bin`/forever -w lb/server.js' \
    > /dev/null
}

function docker_ip ( ) {
    docker inspect "$1" | grep IPAddress | grep -o [[:digit:]\.\]*
}

function clear_hosts ( ) {

    # Remove socket-lb specific entries from hosts file
    start_line="$(grep -n -m1 'START socket-lb' /etc/hosts | grep -oE '^[[:digit:]]*' | xargs)"
    while [ -n "$start_line" ]; do
        end_line="$(grep -n -m1 'END socket-lb' /etc/hosts | grep -oE '^[[:digit:]]*')"
        sudo sed -ie "$start_line","$end_line"d /etc/hosts
        start_line="$(grep -n -m1 'START socket-lb' /etc/hosts | grep -oE '^[[:digit:]]*' | xargs)"
    done

    # Remove trailing newlines from hosts file
    hosts=$(< /etc/hosts);
    echo "$hosts" | sudo tee /etc/hosts > /dev/null
}

function append_hosts ( ) {

    hosts=''
    containers="$(docker ps | grep -E 'socket-lb-\S*' -o)";
    for container in $containers; do
        hosts+=""$(docker_ip $container)" $container""\n"
    done

    echo -e "\n# START socket-lb\n\
# The following lines are automatically generated\n\
$hosts\
# END socket-lb\n" | sudo tee -a /etc/hosts > /dev/null;

}
