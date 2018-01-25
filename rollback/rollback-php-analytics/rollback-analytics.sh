#!/bin/bash
#Load the rollback function scripts,$1：Receive the environment variables
source /tmp/rollback-php-analytics/rollback-env.sh $1 $2
. /tmp/rollback-php-analytics/function-rollback.sh
#Configure each environment running function of rollback PHP server
echo-status rm-analytics
echo-status rollback-analytics
rm -rf /tmp/rollback-php-analytics
