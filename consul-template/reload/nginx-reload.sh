#!/bin/sh
set -e

if [ "$SERVICE_NAME" ]; then consul maint -enable  -service "$SERVICE_NAME" -reason "Consul Template updated"; fi

service nginx reload

if [ "$SERVICE_NAME" ]; then consul maint -disable -service "$SERVICE_NAME"; fi
