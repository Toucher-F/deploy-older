#/bin/bash
case $1 in
	"30QA")
			older_ip_db=10.137.48.139
			older_backup_name=$2
			DATABASE=pre_prod
			ENVIRONMENT_OLD=30QA-older
			RQ=$(date +%Y%m%d)
			;;
	"30prod")
			older_ip_db=10.137.48.146
			older_backup_name=$2
			DATABASE=dealtap
			ENVIRONMENT_OLD=30prod-older
			RQ=$(date +%Y%m%d)
			;;
	"test30QA")
			older_ip_db=10.137.176.67
			older_backup_name=$2
			DATABASE=pre-prod
			ENVIRONMENT_OLD=test30QA-older
			RQ=$(date +%Y%m%d)
			;;
	"test30prod")
			older_ip_db=10.137.176.99
			older_backup_name=$2
			DATABASE=dealtap
			ENVIRONMENT_OLD=test30prod-older
			RQ=$(date +%Y%m%d)
			;;
	*)
		echo "please reset"
		exit 1
		;;
esac
