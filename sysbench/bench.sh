#!/bin/sh
# vim: ft=sh sw=2 ts=2 st=2 sts=2 et

image_name=sysbench
io_tests="seqwr seqrewr seqrd rndrd rndwr rndrw"

iotest() {
  echo "sysbench --test=fileio prepare && sysbench --max-requests=1000000 --file-test-mode=$1 --test=fileio run; sysbench --test=fileio cleanup"
}

header() {
  echo "---------"
  echo $*
  echo "---------"
}

header "Building Docker Image"
docker build -t $image_name .

header "Installing sysbench locally if not already installed"
sudo apt-get install -y sysbench

for io_test in $io_tests
do
  header "Host Machine: I/O Test $io_test"

  bash -c "$(iotest $io_test)"

  header "Docker: I/O Test $io_test"
  docker run -t $image_name bash -c "$(iotest $io_test)"
done
