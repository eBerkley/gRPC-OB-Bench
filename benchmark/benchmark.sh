#!/bin/bash

cd $(dirname $0)/..

./scripts/start.sh

./scripts/pull_stats.sh

./scripts/stop.sh

mv benchmark/imgs benchmark/out/imgs
mv benchmark/stats benchmark/out/stats
mkdir benchmark/imgs
mkdir benchmark/stats