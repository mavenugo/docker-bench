# Docker Benchmarks

These aren't intended to be a definitive "how fast is docker" thing. They're
built to assist with profiling how different a Docker environment will perform
against the bare metal it runs on. 

They are largely meant to be edited by you, the person interested in testing
your hardware. The tooling has been written to make this easier, and it should
be understood that you are responsible for ensuring your benchmarks are both
correct for your workload and accurate.

Please check in each directory for additional instructions for the type of
benchmarks.

All suites assume docker is already installed and running.

## Benchmark Suites

Each directory is its own suite.

* `sysbench/` - basic sysbench benchmarks.
