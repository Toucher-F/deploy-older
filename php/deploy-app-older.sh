#/bin/bash
source /tmp/php/app-php.sh $1 $2
function echo-status {	
		echo "=====================$1 start $(date +%T)===================="
		$1
		is=$?
		if [ $is -eq 0 ]
			then
				echo "$1 success"
		elif [ $is -eq 10 ];then
			echo "" >/dev/null
		else 
			echo "$1 faild"
			sleep 10
			exit 1
		fi
		echo "=====================$1 end $(date +%T)===================="
}
function backup-older-app {
	if
		ssh -o StrictHostKeyChecking=no root@${ip_web} "test -d ${DTPATH}/app-ui -a -d ${DTPATH}/app-core"
	then
		ssh -o StrictHostKeyChecking=no root@${ip_web} "mkdir -p ${DTPATH}/backup/${ENVIRONMENT_OLD}/${older_backup_name}"
		if
			ssh -o StrictHostKeyChecking=no root@${ip_web} "cd ${DTPATH} && tar -zcf ${DTPATH}/backup/${ENVIRONMENT_OLD}/${older_backup_name}/app-ui.tar.gz ./app-ui"
		then
			echo "backup ${ENVIRONMENT_OLD} app-ui succeed"
		else 
			return 1
		fi
		if
			ssh -o StrictHostKeyChecking=no root@${ip_web} "cd ${DTPATH} && tar -zcf ${DTPATH}/backup/${ENVIRONMENT_OLD}/${older_backup_name}/app-core.tar.gz ./app-core"
		then
			echo "backup ${ENVIRONMENT_OLD} app-core succeed"
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
cp ${DTPATH}/app-ui/app/config/config.php ${DTPATH}/app-ui/app/config/config.php.older
cp ${DTPATH}/app-core/app/config/config.php ${DTPATH}/app-core/app/config/config.php.older
if [ -e ${DTPATH}/app-ui/app/config/config.php.older ];then
	cd ${DTPATH}/app-ui/app/config/
	num=$(grep -in "ConfigApi::SOURCE" ./config.php.older | cut -d ":" -f 1)
	j=0
	for i in ${num[@]}
	do
		sed -i ''${i}'c\\t\t\tEnums\\ConfigApi::SOURCE => '\'${ConfigApi_SOURCE[$j]}\'',' ./config.php.older
		((j++))
	done
else
	echo "${DTPATH}/app-ui/app/config/config.php.older File does not exist!"
	return 1
fi

if [ -e ${DTPATH}/app-core/app/config/config.php.older ];then
	cd ${DTPATH}/app-core/app/config/
	sed -i '/Enums\\ConfigAnalytics::SERVICE_URL/c\\t\tEnums\\ConfigAnalytics::SERVICE_URL          => '\'${ConfigAnalytics_SERVICE_URL}\'',' ./config.php.older
	sed -i '/^\t*Enums\\AppFrontEnd::MAIN/,/^[\t]*],*$/c\\t\tEnums\\AppFrontEnd::MAIN => [\n\t\t\tEnums\\ConfigFrontEnd::URL_UI => '\'${AppFrontEnd_MAIN}\'',\n\t\t],' ./config.php.older
	sed -i '/^\t*Enums\\AppFrontEnd::ALPHA/,/^[\t]*],*$/c\\t\tEnums\\AppFrontEnd::ALPHA => [\n\t\t\tEnums\\ConfigFrontEnd::URL_UI => '\'${AppFrontEnd_ALPHA}\'',\n\t\t]' ./config.php.older	
	for ((i=0;i<${#POSTGRES_arguments[@]};i++))
	do
		if [ $i -eq $((${#POSTGRES_arguments[@]}-1)) ];then
			sed -i '/Enums\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\''' ./config.php.older
		else
			sed -i '/Enums\\ConfigPostgres::'${POSTGRES_arguments[$i]}'/c\\t\tEnums\\ConfigPostgres::'${POSTGRES_arguments[$i]}' => '\'${POSTGRES_value[$i]}\'',' ./config.php.older
		fi
	done
	sed -i '/Enums\\ConfigRedis::SERVER/c\\t\tEnums\\ConfigRedis::SERVER => '\'${ConfigRedis_SERVER}\'',' ./config.php.older
	sed -i '/Enums\\ConfigRedis::PORT/c\\t\tEnums\\ConfigRedis::PORT => '\'${ConfigRedis_PORT}\''' ./config.php.older
	sed -i '/Enums\\Config::URL_UI/c\\t\tEnums\\Config::URL_UI => '\'${Config_URL_UI}\'',' ./config.php.older
	sed -i '/Enums\\Config::URL_CORE/c\\t\tEnums\\Config::URL_CORE => '\'${Config_URL_CORE}\'',' ./config.php.older
else
	echo "${DTPATH}/app-core/app/config/config.php.older File does not exist!"
	return 1
fi
return 0
}
function scp-app {
if [ ! -z ${DTPATH} ];then
	cd ${DTPATH}
	if 
		tar -zcf /tmp/app-core.tar.gz ./app-core 
	then
		echo compress app-core succeed
	else
		echo compress app-core faild
		return 1
	fi
	if
		tar -zcf /tmp/app-ui.tar.gz ./app-ui
	then
		echo compress app-ui succeed
	else
		echo compress app-ui faild
		return 1
	fi
	if 
		scp /tmp/app-ui.tar.gz root@${ip_web}:${DTPATH} &>/dev/null
	then
		echo scp app-ui succeed
	else
		echo scp app-ui faild
		return 1
	fi
	if
		scp /tmp/app-core.tar.gz root@${ip_web}:${DTPATH} &>/dev/null
	then
		echo scp app-core succeed
	else
		echo scp app-core faild
		return 1
	fi
		rm -f /tmp/app-core.tar.gz /tmp/app-ui.tar.gz
	if
		ssh -o StrictHostKeyChecking=no root@${ip_web} "cd ${DTPATH} && rm -rf ${DTPATH}/app-ui && rm -rf ${DTPATH}/app-core"
	then
		echo remove older environment app succeed
	else
		echo remove older environment app faild
		return 1
	fi
	if
		ssh -o StrictHostKeyChecking=no root@${ip_web} "cd ${DTPATH} && tar -zxf app-ui.tar.gz && tar -zxf app-core.tar.gz"
	then
		echo unzip older environment app succeed
	else
		echo unzip older environment app faild
		return 1
	fi
		ssh -o StrictHostKeyChecking=no root@${ip_web} "rm -f ${DTPATH}/app-ui.tar.gz ${DTPATH}/app-core.tar.gz "
else
	echo "DTPATH is null"
	return 1
fi
}

function copy-config {
	if
		ssh -o StrictHostKeyChecking=no root@${ip_web} "cp ${DTPATH}/app-ui/app/config/config.php.older ${DTPATH}/app-ui/app/config/config.php" && \
		ssh -o StrictHostKeyChecking=no root@${ip_web} "cp ${DTPATH}/app-core/app/config/config.php.older ${DTPATH}/app-core/app/config/config.php"
	then
		return 0
	else
		return 1
	fi
}
for ip_web in ${older_ip_web[@]}
				do
					if
						ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no root@${ip_web} "pwd" &>/dev/null
					then
						echo-status backup-older-app
						echo-status modify-configuration
						echo-status scp-app
						echo-status copy-config
						rm -rf /tmp/php
					else
						echo "Connect ${ip_web} SSH service failed,Please check the SSH connection"
						exit 1
					fi
				done