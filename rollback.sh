#!/bin/bash
read -t 30 -p "Please input rollback environment[30QA-older/30prod-older/test30QA-older/test30prod-older]?" ENVIRONMENT
if [ -z $ENVIRONMENT ];then
	echo "Environment can't be null"
	exit 1
fi
arr=(30QA-older 30prod-older)
if
	echo ${arr[@]} | grep -wq ${ENVIRONMENT}
then
	DEPLOY_DIR="/30deployment"
else
	DEPLOY_DIR="/storage/deploy"
fi
source /scripts/deploy/environment/environment-ip.sh
TMP_IP="E$(echo $ENVIRONMENT | tr "-" "_")_php"
cd ${DEPLOY_DIR}/backup-older/${ENVIRONMENT}/${!TMP_IP[0]}/app/ && ls -lrt | grep "^d" | awk '{print $9}' 
read -t 60 -p "Please input rollback backup file name[as:30-170220-0_1487746845]?" BACKUP_NAME
if [ -z $BACKUP_NAME ];then
	BACKUP_NAME=$(cd ${DEPLOY_DIR}/backup-older/${ENVIRONMENT}/${TMP_IP[0]}/app/ && ls -lrt | grep "^d" | awk '{print $9}' | tail -n 1)
else
	if
		cat /scripts/deploy-older/older_version/note | grep "${ENVIRONMENT}" | grep  -wq "file name:${BACKUP_NAME}"
	then
		echo "" >/dev/null
	else
		echo "Backup file doesnot exist,please reset!"
		exit 1
	fi
fi
DTPATH=$(sed -n '/^\t*"*'${ENVIRONMENT}'"*/,/;;/p' /scripts/deploy-older/environment/rollback-env.sh | grep DTPATH | cut -d "=" -f 2)
if [ -z $DTPATH ];then
	echo "Failed to get the target server home directory (DTPATH)"
	exit 1
fi
ANAPATH=$(sed -n '/^\t*"*'${ENVIRONMENT}'"*/,/;;/p' /scripts/deploy-older/environment/rollback-env.sh | grep ANAPATH | cut -d "=" -f 2)
if [ -z $ANAPATH ];then
	echo "Failed to get the target server home directory (ANAPATH)"
	exit 1
fi
##############################################################################
#Upload script file to the PHP server $1:ip $2:environment
function deploy-core-php
	{
	scp -r ${DEPLOY_DIR}/backup-older/$2/$1/app/${BACKUP_NAME}/* root@$1:${DTPATH}/
	scp -r /scripts/deploy-older/rollback/rollback-php root@$1:/tmp
	scp /scripts/deploy-older/environment/rollback-env.sh root@$1:/tmp/rollback-php/
	ssh root@$1 . /tmp/rollback-php/rollback-ui-core.sh $2 $BACKUP_NAME
	echo "============================$1 RUNNING OVER============================================"
	}
##############################################################################
#Upload script file to the DB server $1:ip $2:environment
function deploy-core-db
	{
	scp ${DEPLOY_DIR}/backup-older/$2/$1/app/*_${BACKUP_NAME}.dump root@$1:/tmp
	scp -r /scripts/deploy-older/rollback/rollback-db root@$1:/tmp
	scp /scripts/deploy-older/environment/rollback-env.sh root@$1:/tmp/rollback-db/
	ssh root@$1 . /tmp/rollback-db/rollback-db.sh  $2 $BACKUP_NAME
	if [ ! -d /scripts/deploy-older/log/$2/$1 ]
		then
	    mkdir -p /scripts/deploy-older/log/$2/$1 
	fi
		scp root@$1:/var/log/deploy/$2/err_rollback_db_${BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		echo "============================$1 RUNNING OVER============================================"
	}
##############################################################################
#Upload script file to the ANALYTICS PHP server $1:ip $2:environment
function deploy-analytics-php
	{
	scp -r ${DEPLOY_DIR}/backup-older/$2/$1/analytics/${BACKUP_NAME}/* root@$1:${ANAPATH}/
	scp -r /scripts/deploy-older/rollback/rollback-php-analytics root@$1:/tmp
	scp /scripts/deploy-older/environment/rollback-env.sh root@$1:/tmp/rollback-php-analytics/
	ssh root@$1 . /tmp/rollback-php-analytics/rollback-analytics.sh $2 $BACKUP_NAME
	echo "============================$1 RUNNING OVER============================================"
	}
##############################################################################
#Upload script file to the ANALYTICS DB server $1:ip $2:environment
function deploy-analytics-db
	{
	scp ${DEPLOY_DIR}/backup-older/$2/$1/analytics/*_${BACKUP_NAME}.dump root@$1:/tmp
	scp -r /scripts/deploy-older/rollback/rollback-db-analytics root@$1:/tmp
	scp /scripts/deploy-older/environment/rollback-env.sh root@$1:/tmp/rollback-db-analytics/
	ssh root@$1 . /tmp/rollback-db-analytics/rollback-analytics-db.sh $2 $BACKUP_NAME
	if [ ! -d /scripts/deploy-older/log/$2/$1 ]
		then
	    mkdir -p /scripts/deploy-older/log/$2/$1
	fi
		scp root@$1:/var/log/deploy/$2/err_rollback_analytics_db_${BACKUP_NAME}.log /scripts/deploy/log/$2/$1/
		echo "============================$1 RUNNING OVER============================================"
	}
##############################################################################
#Determine the deployment environment and configuration of IP
case $ENVIRONMENT in
			"30QA-older")
				##########################################
				for ip in "${E30QA_older_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT
					deploy-analytics-php $ip $ENVIRONMENT
					deploy-core-db $ip $ENVIRONMENT
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"30prod-older")
				##########################################
				for ip in "${E30prod_older_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT
					deploy-analytics-php $ip $ENVIRONMENT
					deploy-core-db $ip $ENVIRONMENT
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"test30QA-older")
				##########################################
				for ip in "${Etest30QA_older_php[@]}" 
				do
					deploy-core-php $ip $ENVIRONMENT
					deploy-analytics-php $ip $ENVIRONMENT
					deploy-core-db $ip $ENVIRONMENT
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			"test30prod-older")
				##########################################
				for ip in "${Etest30prod_older_php[@]}"
				do
					deploy-core-php $ip $ENVIRONMENT
					deploy-analytics-php $ip $ENVIRONMENT
					deploy-core-db $ip $ENVIRONMENT
					deploy-analytics-db $ip $ENVIRONMENT
				done
				;;
			*)
				echo "please reset"
				;;
esac
