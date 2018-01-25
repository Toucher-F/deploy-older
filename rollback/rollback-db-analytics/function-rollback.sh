#!/bin/bash
function rollback-analytics-db
	{	
					echo "================rollback analytics db start $(date +%T)=========="
					if [ ! -e /var/log/deploy/${ENVIRONMENT} ] 
						then
							mkdir -p /var/log/deploy/${ENVIRONMENT}
					fi
					psql postgres -c "\q" &>/dev/null
					if [ $? -ne 0 ];then
						su - postgres -c "createuser --superuser root" &>/dev/null
					fi
					echo "================rollback analytics db start $(date +%T)==========" >> /var/log/deploy/$ENVIRONMENT/err_rollback_analytics_db_${BACKUP_NAME}.log
					if [ -e /tmp/${ANALYTICS_DATABASE}_${BACKUP_NAME}.dump ]
						then
									cd /tmp					 
									dropdb ${ANALYTICS_DATABASE} && createdb -O dealtap ${ANALYTICS_DATABASE}
									pg_restore -l /tmp/${ANALYTICS_DATABASE}_${BACKUP_NAME}.dump >/tmp/analytics.list
									sed -i -e '/MATERIALIZED VIEW DATA public data_vm_deal_activity dealtap$/{h;d;};/MATERIALIZED VIEW DATA public data_vm_deal_historic dealtap$/G' /tmp/analytics.list
									pg_restore -d ${ANALYTICS_DATABASE}  -L /tmp/analytics.list /tmp/${ANALYTICS_DATABASE}_${BACKUP_NAME}.dump &>> /var/log/deploy/$ENVIRONMENT/err_rollback_analytics_db_${BACKUP_NAME}.log
									if [ $? -eq 0 ]
									then
										echo "rollback analytics db success"
										rm -f /tmp/analytics.list
										rm -f /tmp/${ANALYTICS_DATABASE}_${BACKUP_NAME}.dump
									else 
										echo "rollback analytics db faild"
										echo "rollback analytics db faild" >> /var/log/deploy/$ENVIRONMENT/err_rollback_analytics_db_${BACKUP_NAME}.log
										exit 1
									fi
									
					else 
								echo "rollback analytics db faild,backup-file no find"
								echo "rollback analytics db faild,backup-file no find" >> /var/log/deploy/$ENVIRONMENT/err_rollback_analytics_db_${BACKUP_NAME}.log
								exit 1
					fi
	}