#!/bin/bash
docker run --network 'maxwell-net' --rm -it 'shinkou/kafka' kafka-console-consumer.sh --zookeeper 'maxwell-zookeeper:2181' --topic 'maxwell'
