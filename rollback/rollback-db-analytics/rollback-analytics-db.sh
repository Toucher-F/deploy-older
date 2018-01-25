#!/bin/bash
#Load the rollback function scripts,$1：Receive the environment variables
source /tmp/rollback-db-analytics/rollback-env.sh $1 $2
. /tmp/rollback-db-analytics/function-rollback.sh
#Configure each environment running function of rollback DB server
rollback-analytics-db
rm -rf /tmp/rollback-db-analytics

