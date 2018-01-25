#/bin/bash
source  /tmp/db/app-db.sh $1 $2
function echo-status
	{	
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
function export-database {
psql postgres -c "\q" &>/dev/null
if [ $? -ne 0 ];then
	su - postgres -c "createuser --superuser root" &>/dev/null
fi
if
	psql ${DATABASE} -c "\q" &>/dev/null
then
	if
		pg_dump -Fc ${DATABASE} > /tmp/${DATABASE}_${RQ}.dump
	then
		return 0
	else
		return 1
	fi
else
	echo "root user connection postgresql faild!"
	return 1
fi
}
function scp-database-file {
	if
		scp /tmp/${DATABASE}_${RQ}.dump root@${older_ip_db}:/tmp/ >/dev/null
	then
		return 0
	else
		return 1
	fi
}
function backup-older-database {
	ssh -o StrictHostKeyChecking=no root@${older_ip_db} "psql postgres -c '\q'" &>/dev/null
	if [ $? -ne 0 ];then
		ssh -o StrictHostKeyChecking=no root@${older_ip_db} "su - postgres -c 'createuser --superuser root'" &>/dev/null
	fi
	if 
		ssh -o StrictHostKeyChecking=no root@${older_ip_db} "psql ${DATABASE} -c '\q'" &>/dev/null
	then
			ssh -o StrictHostKeyChecking=no root@${older_ip_db} "mkdir -p /var/backups/deploy/${ENVIRONMENT_OLD}" 
		if
			ssh -o StrictHostKeyChecking=no root@${older_ip_db} "pg_dump -Fc ${DATABASE} > /var/backups/deploy/${ENVIRONMENT_OLD}/${DATABASE}_${older_backup_name}.dump"
		then
			return 0
		else
			return 1
		fi
	else
		echo "${ENVIRONMENT_OLD} ${DATABASE} database does not exist!"
		return 10
	fi
}
function import-database {
	if
	ssh -o StrictHostKeyChecking=no root@${older_ip_db} "dropdb ${DATABASE} && createdb -O dealtap ${DATABASE} && pg_restore -d ${DATABASE} /tmp/${DATABASE}_${RQ}.dump" &>/dev/null
	then
		return 0
	else
		return 1
	fi
}
function remove-tmpfile {
	if
		ssh -o StrictHostKeyChecking=no root@${older_ip_db} "rm -f /tmp/${DATABASE}_${RQ}.dump"
	then
		rm -f /tmp/${DATABASE}_${RQ}.dump
		rm -rf /tmp/db
		return 0
	else
		return 1
	fi
}
if
	ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no root@${older_ip_db} "pwd" &>/dev/null
then
	echo-status export-database
	echo-status scp-database-file
	echo-status backup-older-database
	echo-status import-database
	echo-status remove-tmpfile
else
	echo "Connect ${older_ip_db} SSH service failed,Please check the SSH connection"
	exit 1
fi

