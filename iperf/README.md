# Network Performance Tests

We use [iperf](http://iperf.sf.net) to orchestrate some network tests and how
docker/lxc affect the performance vs. host-only performance. This is not
intended to be a thorough benchmark of network performance, but to compare and
constrast what running locally vs. between the container and the host will be
like.

# Test Plan

Tests are for both TCP and UDP

* Host only test: iperf over localhost
* Docker Test 1: iperf client from the host to docker server

# Current Issues

iperf tends to lock up starting the server, leaving some cleanup and not
finishing the tests. At this time I do not have a solution to this problem.

Running the lxc tests for UDP, iperf will complain that it has lost the last
two datagrams. I don't think this is an issue, but it should be mentioned.
