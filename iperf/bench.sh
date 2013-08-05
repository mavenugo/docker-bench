#!/bin/sh
# vim: ft=sh sw=2 ts=2 st=2 sts=2 et
#
# NOTE
#
# see the bottom of this script for all the test batteries executed as
# functions -- comment out what you don't want to run!
#
# edit the variables below to tweak some common parameters.

# by default, set to number of cpus
# just change this to a number if you want to use something fixed
num_threads=$(cat /proc/cpuinfo | grep processor | wc -l)
image_name=iperf

header() {
  echo
  echo "----------------------------------------------------------------------"
  echo $*
  echo "----------------------------------------------------------------------"
  echo
}

build_docker_image() {
  header "Building Docker Image"
  docker build -t $image_name .
}

install_iperf() {
  header "Installing iperf locally if not already installed"
  apt-get install -y iperf
  hash -r
}

run_tcp_test() {
  header "TCP Test: localhost only"
  iperf -s -D
  iperf -f m -c localhost -P ${num_threads}
  killall -KILL iperf

  header "TCP Test: through bridge"
  docker run -p 5001 -t $image_name bash -c "iperf -s" &
  sleep 1
  docker_container=$(docker ps -q)
  docker_port=$(docker port ${docker_container} 5001)
  iperf -f m -c localhost -p ${docker_port} -P ${num_threads}
  docker stop ${docker_container}
  docker rm ${docker_container}
  
  header "TCP Test: Docker <-> Docker through host bridge"
  docker run -p 5001 -t $image_name bash -c "iperf -s" &
  sleep 1
  docker_container=$(docker ps -q)
  docker_port=$(docker port ${docker_container} 5001)
  docker run -t iperf bash -c "iperf -f m -c \$(ip route | head -1 | awk '{ print \$3 }') -p ${docker_port} -P ${num_threads}"
  docker stop ${docker_container}
  docker rm ${docker_container}
}

run_udp_test() {
  header "UDP Test: localhost only"
  iperf -u -s -D
  iperf -f m -u -c localhost -P ${num_threads}
  killall -KILL iperf

  header "UDP Test: through bridge"
  docker run -p 5001 $image_name bash -c "iperf -u -s" &
  sleep 1
  docker_container=$(docker ps -q)
  docker_port=$(docker port ${docker_container} 5001)
  iperf -f m -u -c localhost -p ${docker_port} -P ${num_threads}
  docker stop ${docker_container}
  docker rm ${docker_container}
  
  header "UDP Test: Docker <-> Docker through host bridge"
  docker run -p 5001 -t $image_name bash -c "iperf -u -s" &
  sleep 1
  docker_container=$(docker ps -q)
  docker_port=$(docker port ${docker_container} 5001)
  docker run -t iperf bash -c "iperf -f m -u -c \$(ip route | head -1 | awk '{ print \$3 }') -p ${docker_port} -P ${num_threads}"
  docker stop ${docker_container}
  docker rm ${docker_container}
}

build_docker_image
install_iperf
run_tcp_test
run_udp_test
