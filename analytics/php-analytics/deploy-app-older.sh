#/bin/bash
source /tmp/php-analytics/analytics-php.sh
function echo-status {	
		echo "=====================$1 start $(date +%T)===================="
		$1
		is=$?
		if [ $is -eq 0 ]
			then
				echo "$1 success"
		elif [ $is -eq 10 ];then
			echo ""
		else 
			echo "$1 faild"
			sleep 10
			exit 1
		fi
		echo "=====================$1 end $(date +%T)===================="
}
function backup-older-app {
	if
		ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "test -d ${ANAPATH}/analytics"
	then
		ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "mkdir -p ${ANAPATH}/backup/analytics/${ENVIRONMENT_OLD}/${older_backup_name}"
		if
			ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "cd ${ANAPATH} && tar -zcf ${ANAPATH}/backup/analytics/${ENVIRONMENT_OLD}/${older_backup_name}/analytics.tar.gz ./analytics"
		then
			echo "backup ${ENVIRONMENT_OLD} analytics succeed"
		else 
			return 1
		fi
		return 0
	else
		echo "${ENVIRONMENT_OLD} Project directory does not exist!"
		return 10
	fi
}
function modify-configuration {

cp ${ANAPATH}/analytics/source/config/config.php ${ANAPATH}/analytics/source/config/config.php.older
if [ -e ${ANAPATH}/analytics/source/config/config.php.older ];then
	cd ${ANAPATH}/analytics/source/config/
	sed -i '/Enum\\ConfigAuth::WHITELISTED_IPS/,/^[\t]*],$/c\\t\tEnum\\ConfigAuth::WHITELISTED_IPS => [\n\t\t],' ./config.php.older
	for str in ${WHITELISTED_IPS[@]}
		do
			sed -i '/Enum\\ConfigAuth::WHITELISTED_IPS/a\\t\t\t'\'${str}\'',' ./config.php.older
		done
	for ((i=0;i<${#POSTGRES_arguments[@]};i++))
	do
		if [ $i -eq $((${#POSTGRES_arguments[@]}-1)) ];then
			sed -i '/Enums*\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\''' ./config.php.older
		else
			sed -i '/Enums*\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\'',' ./config.php.older
		fi
	done
else
	echo "${ANAPATH}/analytics/source/config/config.php.older File does not exist!"
	return 1
fi
}
function scp-analytics {
if [ ! -z ${ANAPATH} ];then
	cd ${ANAPATH}
	if 
		tar -zcf /tmp/analytics.tar.gz ./analytics
	then
		echo compress analytics succeed
	else
		echo compress analytics faild
		return 1
	fi
	if 
		scp /tmp/analytics.tar.gz root@${older_analytics_ip_web}:${ANAPATH} &>/dev/null
	then
		echo scp analytics succeed
	else
		echo scp analytics faild
		return 1
	fi
		rm -f /tmp/analytics.tar.gz
	if
		ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "cd ${ANAPATH} && rm -rf ${ANAPATH}/analytics"
	then
		echo remove older environment analytics succeed
	else
		echo remove older environment analytics faild
		return 1
	fi
	if
		ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "cd ${ANAPATH} && tar -zxf analytics.tar.gz"
	then
		echo unzip older environment analytics succeed
	else
		echo unzip older environment analytics faild
		return 1
	fi
		ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "rm -f ${ANAPATH}/analytics.tar.gz"
else
	echo "ANAPATH is null"
	return 1
fi

}
function copy-config {
	if
		ssh -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "cp ${ANAPATH}/analytics/source/config/config.php.older ${ANAPATH}/analytics/source/config/config.php"
	then
		return 0
	else
	
		return 1
	fi
}
if
	ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no root@${older_analytics_ip_web} "pwd" &>/dev/null
then
	echo-status backup-older-app
	echo-status modify-configuration
	echo-status scp-analytics
	echo-status copy-config
	rm -rf /tmp/php-analytics
else
	echo "Connect ${older_analytics_ip_web} SSH service failed,Please check the SSH connection"
	exit 1
fi

