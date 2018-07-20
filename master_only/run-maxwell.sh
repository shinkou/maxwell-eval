#!/bin/bash
docker run --network 'maxwell-net' --name 'maxwell-daemon' --rm -it 'zendesk/maxwell' bin/maxwell --host='maxwell-mysql' --user='maxwell' --password='maxwell-secret' --producer=kafka --kafka_version='0.10.0.1' --kafka.bootstrap.servers='maxwell-kafka:9092' --kafka_topic='maxwell'
