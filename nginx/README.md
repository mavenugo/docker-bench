# nginx tests

These tests use [wrk](https://github.com/wg/wrk) tool to exercise nginx. They
manipulate and control both the nginx configuration and the service itself. It
will also stop and remove all running docker containers for some of the tests.

As the main README recommends, it is strongly advised you do not run this on
any system with critical roles.

## Test plan 

We make use of the [open_file_cache
parameter](http://wiki.nginx.org/HttpCoreModule#open_file_cache) to demonstrate
the difference between nginx serving off of disk and straight out of memory.
Suggestions on further configuration in this regard would be greatly
appreciated.

Tests are executed both with `open_file_cache` on and off.

* Host Test: wrk for 1m against local nginx.
* Docker Internal Test: wrk for 1m against local nginx inside docker fully.
* Host To Docker Test: wrk for 1m on local machine against docker running nginx.
