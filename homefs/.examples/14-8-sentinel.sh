#!/bin/bash
while ! ping -c 1 redis-0.redis; do
    echo 'Waiting for server'
    sleep 1
done

SENTINEL_CFG=/tmp/sentinel.conf
cp /redis-config/sentinel.conf "$SENTINEL_CFG"

redis-sentinel "$SENTINEL_CFG"

