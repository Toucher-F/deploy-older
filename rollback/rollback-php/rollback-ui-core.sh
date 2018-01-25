#!/bin/bash
#Load the rollback function scripts ,$1：Receive the environment variables
source /tmp/rollback-php/rollback-env.sh $1 $2
. /tmp/rollback-php/function-rollback.sh
#Configure each environment running function of rollback PHP server
echo-status rm-ui-core
echo-status rollback
rm -rf /tmp/rollback-php
