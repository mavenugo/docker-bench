#!/bin/sh
# vim: ft=sh sw=2 ts=2 st=2 sts=2 et

max_requests=1000000
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

header "Building Docker Image"
docker build -t $image_name .

header "Installing sysbench locally if not already installed"
apt-get install -y sysbench

for io_test in $io_tests
do
  header "Host Machine: I/O Test $io_test"

  bash -c "$(iotest $io_test)"

  header "Docker: I/O Test $io_test"
  docker run -t $image_name bash -c "$(iotest $io_test)"
done

header "Host Machine CPU Battery"
sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run

header "Docker CPU Battery"
docker run -t $image_name sysbench --num-threads=${num_threads} --max-requests=${max_requests} --test=cpu run
