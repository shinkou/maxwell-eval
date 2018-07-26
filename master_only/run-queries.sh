#!/bin/bash
docker run --network 'maxwell-net' --rm -it 'mysql:5.7.21' mysql -hmaxwell-mysql -uroot -psecret
