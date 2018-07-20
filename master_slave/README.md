# Maxwell's Daemon Evaluation (Master-Slave Arch)

### How To Use

First, prepare the cluster with:

```
$ ./mk-pcluster.sh all
```

It will show you some info for verification and prompt you to whether
continue the setup, or stop and run custom queries to finalize it manually.

After the setup has finished, you could execute the Maxwell's daemon:

```
$ ./run-maxwell.sh
```

Then, run the following to watch the Kafka topic:

```
$ ./watch-maxwell.sh
```

Finally, connect to the MySQL database and explore.

```
$ ./run-queries.sh
```

