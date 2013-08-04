#!/bin/sh
# vim: ft=sh sw=2 ts=2 st=2 sts=2 et
#
# NOTE
#
# see the bottom of this script for all the test batteries executed as
# functions -- comment out what you don't want to run!
#
# edit the variables below to tweak some common parameters.

max_requests=100000
# by default, set to number of cpus
# just change this to a number if you want to use something fixed
num_threads=$(cat /proc/cpuinfo | grep processor | wc -l)
image_name=sysbench
io_tests="seqwr seqrewr seqrd rndrd rndwr rndrw"

iotest() {
  echo "sysbench --test=fileio prepare && sysbench --num-threads=${num_threads} --max-requests=${max_requests} --file-test-mode=$1 --test=fileio run; sysbench --test=fileio cleanup"
}

header() {
  echo
  echo "---------"
  echo $*
  echo "---------"
  echo
}

build_docker_image() {
  header "Building Docker Image"
  docker build -t $image_name .
}

install_sysbench() {
  header "Installing sysbench locally if not already installed"
  apt-get install -y sysbench
}

run_io_tests() { 
  for io_test in $io_tests
  do
    header "Host Machine: I/O Test $io_test"

    bash -c "$(iotest $io_test)"

    header "Docker: I/O Test $io_test"
    docker run -t $image_name bash -c "$(iotest $io_test)"
  done
}

run_cpu_tests() {
  header "Host Machine CPU Battery"
  sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run

  header "Docker CPU Battery"
  docker run -t $image_name sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run
}

build_docker_image
install_sysbench
run_io_tests
run_cpu_tests
