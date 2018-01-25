#/bin/bash
read -t 30 -p "Please input the project environment[30QA/30prod/test30QA/test30prod]?" ENVIRONMENT
if [ -z $ENVIRONMENT ];then
	echo "Environment cannot be null"
	exit 1
fi
arr=(30QA 30staging 30prod)
if
	echo ${arr[@]} | grep -wq ${ENVIRONMENT}
then
	DEPLOY_DIR="/30deployment"
else
	DEPLOY_DIR="/storage/deploy"
fi
source /scripts/deploy/environment/environment-ip.sh
DTPATH=$(sed -n '/^\t*"*'${ENVIRONMENT}'"*/,/;;/p' /scripts/deploy-older/environment/app-php.sh | grep DTPATH | cut -d "=" -f 2)
if [ -z $DTPATH ];then
	echo "Failed to get the target server home directory (DTPATH)"
	exit 1
fi
ANAPATH=$(sed -n '/^\t*"*'${ENVIRONMENT}'"*/,/;;/p' /scripts/deploy-older/environment/analytics-php.sh | grep ANAPATH | cut -d "=" -f 2)
if [ -z $ANAPATH ];then
	echo "Failed to get the target server home directory (ANAPATH)"
	exit 1
fi
#Upload script file to the PHP server $1:ip $2:environment
function deploy-core-php
	{
		scp -r /scripts/deploy-older/php root@$1:/tmp/
		scp /scripts/deploy-older/environment/app-php.sh root@$1:/tmp/php/
		ssh root@$1 . /tmp/php/deploy-app-older.sh $2 $3
		older_env="E${ENVIRONMENT}_older_php[@]"
		older_env=(${!older_env})
		for i in ${older_env[@]}
		do
			if [ ! -d ${DEPLOY_DIR}/backup-older/$2-older/$i/app ];then
				mkdir -p ${DEPLOY_DIR}/backup-older/$2-older/$i/app
			fi
			if
				scp -rp root@$i:${DTPATH}/backup/${ENVIRONMENT}-older/* ${DEPLOY_DIR}/backup-older/$2-older/$i/app/
			then
				echo "Transer backup files back successfully"
				ssh root@$i "rm -rf ${DTPATH}/backup/${ENVIRONMENT}-older/*"
			else
				echo "Transer backup files back faild"
			fi
		done
		echo "============================$1 RUNNING OVER============================================"
	}
##############################################################################
#Upload script file to the DB server $1:ip $2:environment
function deploy-core-db
	{
		scp -r /scripts/deploy-older/db root@$1:/tmp/
		scp /scripts/deploy-older/environment/app-db.sh root@$1:/tmp/db/
		ssh root@$1 . /tmp/db/deploy-db-older.sh $2 $3
		older_env="E${ENVIRONMENT}_older_db[@]"
		older_env=(${!older_env})
		for i in ${older_env[@]}
		do
			if [ ! -d ${DEPLOY_DIR}/backup-older/$2-older/$i/app ];then
				mkdir -p ${DEPLOY_DIR}/backup-older/$2-older/$i/app
			fi
			if
				scp -p root@$i:/var/backups/deploy/${ENVIRONMENT}-older/* ${DEPLOY_DIR}/backup-older/$2-older/$i/app/
			then
				echo "Transer backup files back successfully"
				ssh root@$i "rm -rf /var/backups/deploy/${ENVIRONMENT}-older/*"
			else
				echo "Transer backup files back faild"
			fi
		done
		echo "============================$1 RUNNING OVER============================================"
	}
function deploy-analytics-php
	{
		scp -r /scripts/deploy-older/analytics/php-analytics root@$1:/tmp
		scp /scripts/deploy-older/environment/analytics-php.sh root@$1:/tmp/php-analytics/
		ssh root@$1 . /tmp/php-analytics/deploy-app-older.sh $2 $3
		older_env="E${ENVIRONMENT}_older_analytics_php[@]"
		older_env=(${!older_env})
		for i in ${older_env[@]}
		do
			if [ ! -d ${DEPLOY_DIR}/backup-older/$2-older/$i/analytics ]
			then
			mkdir -p ${DEPLOY_DIR}/backup-older/$2-older/$i/analytics
		fi
			if
				scp -rp root@$i:${ANAPATH}/backup/analytics/${ENVIRONMENT}-older/* ${DEPLOY_DIR}/backup-older/$2-older/$i/analytics/
			then
				echo "Transer backup files back successfully"
				ssh root@$i "rm -rf ${ANAPATH}/backup/analytics/${ENVIRONMENT}-older/*"
			else
				echo "Transer backup files back faild"
			fi
		done
		echo "============================$1 RUNNING OVER============================================"
	}
##############################################################################
#Upload script file to the ANALYTICS DB server $1:ip $2:environment
function deploy-analytics-db
	{
		scp -r /scripts/deploy-older/analytics/db-analytics root@$1:/tmp
		scp /scripts/deploy-older/environment/analytics-db.sh root@$1:/tmp/db-analytics/
		ssh root@$1 . /tmp/db-analytics/deploy-db-older.sh $2 $3
		older_env="E${ENVIRONMENT}_older_analytics_db[@]"
		older_env=(${!older_env})
		for i in ${older_env[@]}
		do
			if [ ! -d ${DEPLOY_DIR}/backup-older/$2-older/$i/analytics ]
			then
			mkdir -p ${DEPLOY_DIR}/backup-older/$2-older/$i/analytics
		fi
			if
				scp -p root@$i:/var/backups/deploy/analytics/${ENVIRONMENT}-older/* ${DEPLOY_DIR}/backup-older/$2-older/$i/analytics/
			then
				echo "Transer backup files back successfully"
				ssh root@$i "rm -rf /var/backups/deploy/analytics/${ENVIRONMENT}-older/*"
			else
				echo "Transer backup files back faild"
			fi
		done
	echo "============================$1 RUNNING OVER============================================"
	}
case $ENVIRONMENT in
			"30QA")
				if
					ssh -o StrictHostKeyChecking=no root@${E30QA_older_php[0]} "test -d ${E30QA_older_DT_path}/app-ui"
				then
					older_build_number=$(ssh -o StrictHostKeyChecking=no root@${E30QA_older_php[0]} "cd ${E30QA_older_DT_path}/app-ui && git branch | grep '^*' | awk '{printf \$2}'")
					older_backup_name="${older_build_number}_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh,generate older environment backup file name:${older_backup_name}" >>/scripts/deploy-older/older_version/note
				else
					older_backup_name="30-$(date '+%y-%m-%d')-0_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh" >>/scripts/deploy-older/older_version/note
				fi
				for ip in "${E30QA_db[0]}" 
				do
					deploy-core-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${E30QA_php[0]}" 
				do
					deploy-core-php $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${E30QA_analytics_db[0]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${E30QA_analytics_php[0]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT $older_backup_name
				done
				;;
			"30prod")
				if
					ssh -o StrictHostKeyChecking=no root@${E30prod_older_php[0]} "test -d ${E30prod_older_DT_path}/app-ui"
				then
					older_build_number=$(ssh -o StrictHostKeyChecking=no root@${E30prod_older_php[0]} "cd ${E30prod_older_DT_path}/app-ui && git branch | grep '^*' | awk '{printf \$2}'")
					older_backup_name="${older_build_number}_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh,generate older environment backup file name:${older_backup_name}" >>/scripts/deploy-older/older_version/note
				else
					older_backup_name="30-$(date '+%y-%m-%d')-0_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh" >>/scripts/deploy-older/older_version/note
				fi
				for ip in "${E30prod_db[0]}" 
				do
					deploy-core-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${E30prod_php[0]}" 
				do
					deploy-core-php $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${E30prod_analytics_db[0]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${E30prod_analytics_php[0]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT $older_backup_name
				done
				;;
#################################################### TEST  ##########################################################################
			"test30QA")
				if
					ssh -o StrictHostKeyChecking=no root@${Etest30QA_older_php[0]} "test -d ${Etest30QA_older_DT_path}/app-ui"
				then
					older_build_number=$(ssh -o StrictHostKeyChecking=no root@${Etest30QA_older_php[0]} "cd ${Etest30QA_older_DT_path}/app-ui && git branch | grep '^*' | awk '{printf \$2}'")
					older_backup_name="${older_build_number}_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh,generate older environment backup file name:${older_backup_name}" >>/scripts/deploy-older/older_version/note
				else
					older_backup_name="30-$(date '+%y-%m-%d')-0_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh" >>/scripts/deploy-older/older_version/note
				fi
				for ip in "${Etest30QA_db[0]}" 
				do
					deploy-core-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${Etest30QA_php[0]}" 
				do
					deploy-core-php $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${Etest30QA_analytics_db[0]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${Etest30QA_analytics_php[0]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT $older_backup_name
				done
				;;
			"test30prod")
				if
					ssh -o StrictHostKeyChecking=no root@${Etest30prod_older_php[0]} "test -d ${Etest30prod_older_DT_path}/app-ui"
				then
					older_build_number=$(ssh -o StrictHostKeyChecking=no root@${Etest30prod_older_php[0]} "cd ${Etest30prod_older_DT_path}/app-ui && git branch | grep '^*' | awk '{printf \$2}'")
					older_backup_name="${older_build_number}_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh,generate older environment backup file name:${older_backup_name}" >>/scripts/deploy-older/older_version/note
				else
					older_backup_name="30-$(date '+%y-%m-%d')-0_$(date +%s)"
					echo "${ENVIRONMENT}-older:$(date '+%Y-%m-%d %T') perform deploy-older.sh" >>/scripts/deploy-older/older_version/note
				fi
				for ip in "${Etest30prod_db[0]}" 
				do
					deploy-core-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${Etest30prod_php[0]}" 
				do
					deploy-core-php $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${Etest30prod_analytics_db[0]}" 
				do
					deploy-analytics-db $ip $ENVIRONMENT $older_backup_name
				done
				##########################################
				for ip in "${Etest30prod_analytics_php[0]}" 
				do
					deploy-analytics-php $ip $ENVIRONMENT $older_backup_name
				done
				;;
			*)
			echo "please reset"
			;;
esac

