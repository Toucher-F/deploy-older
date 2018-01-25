#/bin/bash
case $1 in
	"30QA") 
			older_analytics_ip_web=10.137.48.139
			ENVIRONMENT_OLD=30QA-older
			older_backup_name=$2
			ANAPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			#-------analytics config file argument start--------
			WHITELISTED_IPS=(138.197.154.50 10.137.48.146 127.0.0.1)
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap analytics)
			#-------scp-analytics config file argument end----------
			;;
	"30prod") 
			older_analytics_ip_web=10.137.48.146
			ENVIRONMENT_OLD=30prod-older
			older_backup_name=$2
			ANAPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			#-------analytics config file argument start--------
			WHITELISTED_IPS=(138.197.150.48 10.137.48.146 127.0.0.1)
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap analytics)
			#-------scp-analytics config file argument end----------
			;;
	"test30QA") 
			older_analytics_ip_web=10.137.176.67
			ENVIRONMENT_OLD=test30QA-older
			older_backup_name=$2
			ANAPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			#-------analytics config file argument start--------
			WHITELISTED_IPS=(159.203.22.90 10.137.176.67 127.0.0.1)
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap analytics)
			#-------scp-analytics config file argument end----------
			;;
	"test30prod") 
			older_analytics_ip_web=10.137.176.99
			ENVIRONMENT_OLD=test30prod-older
			older_backup_name=$2
			ANAPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			#-------analytics config file argument start--------
			WHITELISTED_IPS=(138.197.145.128 10.137.176.99 127.0.0.1)
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap analytics)
			#-------scp-analytics config file argument end----------
			;;
esac
