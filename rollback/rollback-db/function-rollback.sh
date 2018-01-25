#!/bin/bash
function rollback_databases
	{
		# rollback  DATABASE
				echo "================rollback db start $(date +%T)=========="
				if [ ! -e /var/log/deploy/${ENVIRONMENT} ] 
					then
						mkdir -p /var/log/deploy/${ENVIRONMENT}
				fi
				psql postgres -c "\q" &>/dev/null
				if [ $? -ne 0 ];then
					su - postgres -c "createuser --superuser root" &>/dev/null
				fi
				echo "================rollback db start $(date +%T)==========" >> /var/log/deploy/$ENVIRONMENT/err_rollback_db_${BACKUP_NAME}.log
				if [ -e /tmp/${DATABASE}_${BACKUP_NAME}.dump ]
					then
						cd /tmp/
						dropdb ${DATABASE} && createdb -O dealtap ${DATABASE} && pg_restore -d ${DATABASE} /tmp/${DATABASE}_${BACKUP_NAME}.dump &>> /var/log/deploy/$ENVIRONMENT/err_rollback_db_${BACKUP_NAME}.log
						if [ $? -eq 0 ]
						then
							echo "rollback db success"	
						else 
							echo "rollback db faild"
							echo "rollback db faild" >> /var/log/deploy/$ENVIRONMENT/err_rollback_db_${BACKUP_NAME}.log
							exit 1
						fi
				else 
					echo "rollback db faild,backup-file no find"
					echo "rollback db faild,backup-file no find" >> /var/log/deploy/$ENVIRONMENT/err_rollback_db_${BACKUP_NAME}.log
					exit 1
				fi
	}