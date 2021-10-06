# Process

Get an equinix machine, EQUINIX

In an empty directory (eg /root/clean) build the Dockerfile in this directory.

At the same time, download the trace from COMANCHE (to a different dir): `make download_repr`

When Dockerfile has built, copy the tree.exe executable out of the
docker container (`make cp_from_container`), and run it against the trace. 

You probably need to install all the shared libraries in the host:
librocksdb-dev, libkyotocabinet-dev and possibly some others (use `ldd
tree.exe` to see).

For librocksdb (6.11), from this page: https://launchpad.net/ubuntu/+source/rocksdb

```
wget https://launchpad.net/ubuntu/+archive/primary/+files/librocksdb6.11_6.11.4-3_amd64.deb
dpkg -i ./lib*.deb # maybe before this, install libgflags and libsnappy
```

# Running a benchmark

I do something like this:

```
export N=1343496 
export T=data_1343496commits.repr 
/tmp/tree.exe --mode=trace --keep-stat-trace --keep-store --ncommits-trace=$N $T

# or...
nohup /tmp/tree.exe --mode=trace --keep-stat-trace --keep-store --ncommits-trace=$N $T >out 2>&1

```

You can even do this while the other process is downloading the repr
trace (assuming the download keeps ahead of the tree.exe replay).


# References

Ioana's scripts: 

- https://github.com/tarides/irmin-tezos/blob/master/bench.sh
- https://github.com/tarides/irmin-tezos/blob/master/summarise.sh
