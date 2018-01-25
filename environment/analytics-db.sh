#/bin/bash
case $1 in
	"30QA")
			older_analytics_ip_db=10.137.48.139
			older_backup_name=$2
			DATABASE=analytics
			ENVIRONMENT_OLD=30QA-older
			RQ=$(date +%Y%m%d)
			;;
	"30prod")
			older_analytics_ip_db=10.137.48.146
			older_backup_name=$2
			DATABASE=analytics
			ENVIRONMENT_OLD=30prod-older
			RQ=$(date +%Y%m%d)
			;;
	"test30QA")
			older_analytics_ip_db=10.137.176.67
			older_backup_name=$2
			DATABASE=analytics
			ENVIRONMENT_OLD=test30QA-older
			RQ=$(date +%Y%m%d)
			;;
	"test30prod")
			older_analytics_ip_db=10.137.176.99
			older_backup_name=$2
			DATABASE=analytics
			ENVIRONMENT_OLD=test30prod-older
			RQ=$(date +%Y%m%d)
			;;
esac