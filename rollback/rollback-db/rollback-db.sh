#!/bin/bash
#Load the rollback function scripts,$1：Receive the environment variables
source /tmp/rollback-db/rollback-env.sh $1 $2
. /tmp/rollback-db/function-rollback.sh
#Configure each environment running function of rollback DB server
rollback_databases
rm -rf /tmp/rollback-db
