#!/bin/sh
# vim: ft=sh sw=2 ts=2 st=2 sts=2 et
#
# NOTE
#
# see the bottom of this script for all the test batteries executed as
# functions -- comment out what you don't want to run!
#
# edit the variables below to tweak some common parameters.

# these are parameters to the `wrk` utility at
# https://github.com/wg/wrk 
# Please see the help for additional parameters / documentation
open_connections=200
time_to_run=60s
# by default, set to number of cpus
# just change this to a number if you want to use something fixed
num_threads=$(cat /proc/cpuinfo | grep processor | wc -l)
image_name=nginx

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

install_nginx() {
  header "Installing nginx locally if not already installed"
  apt-get install -y nginx
  header "Turning off nginx's service so we can run it ourselves"
  service nginx stop
}

install_wrk() {
  header "Installing wrk locally"
  apt-get install -y build-essential git-core libssl-dev
  if ! which wrk 2>&1 >/dev/null
  then
    git clone https://github.com/wg/wrk 
    cd wrk 
    make 
    cp wrk /usr/local/bin
    hash -r
  fi
}

add_file_cache() {
  echo "sed -i 's/# @OPEN_FILE_CACHE@/open_file_cache max=500;/' /etc/nginx/nginx.conf"
}

cleanup_nginx_config() {
  header "Resetting nginx configuration on local machine"
  cp nginx.conf /etc/nginx/nginx.conf
}

start_nginx() {
  echo "killall nginx 2>&1 >/dev/null; nginx"
}

run_wrk() {
  echo "wrk -c ${open_connections} -d ${time_to_run} -t ${num_threads} http://localhost:${1}"
}

run_nocache_test() { 
  cleanup_nginx_config
  header "Running local test against port 80 with no open file cache"
  bash -c "$(start_nginx); $(run_wrk 80)"

  header "Docker Test 1: Locally in Docker against port 80 with no open file cache"
  docker run -t $image_name bash -c "$(start_nginx); $(run_wrk 80)"
}

run_cache_test() {
  cleanup_nginx_config
  header "Running local test against port 80 with open file cache"
  bash -c "$(add_file_cache); $(start_nginx); $(run_wrk 80)"

  header "Docker Test 1: Locally in Docker against port 80 with open file cache"
  docker run -t $image_name bash -c "$(add_file_cache); $(start_nginx); $(run_wrk 80)"
}

build_docker_image
install_nginx
install_wrk
run_nocache_test
run_cache_test
