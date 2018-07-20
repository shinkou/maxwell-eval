# Maxwell's Daemon Evaluation (Master only)

### How To Use

First, issue these commands

```
$ ./mk-pcluster.sh all
$ ./run-maxwell.sh
```

to generate all necessary containers and run the Maxwell's daemon.

Then, run the following to watch the Kafka topic:

```
$ ./watch-maxwell.sh
```

Finally, connect to the MySQL database and explore.

```
$ ./run-queries.sh
```
