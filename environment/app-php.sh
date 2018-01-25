#/bin/bash
case $1 in
	"30QA") 
			ENVIRONMENT_OLD=30QA-older
			DTPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			older_backup_name=$2
			older_ip_web=(10.137.48.139)
			#-------App-core config file argument start--------
			ConfigAnalytics_SERVICE_URL="analytics.30qaold.dealtap.ca"
			AppFrontEnd_MAIN="http://app.30qaold.dealtap.ca/"
			AppFrontEnd_ALPHA="http://app.30qaold.dealtap.ca/"
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap pre_prod)
			ConfigRedis_SERVER="localhost"
			ConfigRedis_PORT=6739
			Config_URL_UI="http://app.30qaold.dealtap.ca"
			Config_URL_CORE="http://api.30qaold.dealtap.ca"
			#-------App-core config file argument end----------
			#-------App-ui config file argument start----------
			#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
			ConfigApi_SOURCE=(http://api.30qaold.dealtap.ca/api http://dealtap-analytics/api)
			#-------App-ui config file argument end------------

			;;
	"30prod") 
			ENVIRONMENT_OLD=30prod-older
			DTPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			older_backup_name=$2
			older_ip_web=(10.137.48.146)
			#-------App-core config file argument start--------
			ConfigAnalytics_SERVICE_URL="analytics.doldprod.dealtap.ca"
			AppFrontEnd_MAIN="http://app.doldprod.dealtap.ca/"
			AppFrontEnd_ALPHA="http://app.doldprod.dealtap.ca/"
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap dealtap)
			ConfigRedis_SERVER="localhost"
			ConfigRedis_PORT=6739
			Config_URL_UI="http://app.doldprod.dealtap.ca"
			Config_URL_CORE="http://app.doldprod.dealtap.ca"
			#-------App-core config file argument end----------
			#-------App-ui config file argument start----------
			#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
			ConfigApi_SOURCE=(http://api.doldprod.dealtap.ca/api http://analytics.doldprod.dealtap.ca/api)
			#-------App-ui config file argument end------------
			;;
################################################################################################################
	"test30QA") 
			ENVIRONMENT_OLD=test30QA-older
			DTPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			older_backup_name=$2
			older_ip_web=(10.137.176.67)
			#-------App-core config file argument start--------
			ConfigAnalytics_SERVICE_URL="analytics.dqaold.dealtap.ca"
			AppFrontEnd_MAIN="http://app.dqaold.dealtap.ca/"
			AppFrontEnd_ALPHA="http://app.dqaold.dealtap.ca/"
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap pre-prod)
			ConfigRedis_SERVER="localhost"
			ConfigRedis_PORT=6739
			Config_URL_UI="http://app.dqaold.dealtap.ca"
			Config_URL_CORE="http://api.dqaold.dealtap.ca"
			#-------App-core config file argument end----------
			#-------App-ui config file argument start----------
			#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
			ConfigApi_SOURCE=(http://api.dqaold.dealtap.ca/api http://analytics.dqaold.dealtap.ca/api)
			#-------App-ui config file argument end------------
			;;
	"test30prod") 
			ENVIRONMENT_OLD=test30prod-older
			DTPATH=/media/sf_src
			RQ=$(date +%Y%m%d)
			older_backup_name=$2
			older_ip_web=(10.137.176.99)
			#-------App-core config file argument start--------
			ConfigAnalytics_SERVICE_URL="analytics.doldprod.dealtap.ca"
			AppFrontEnd_MAIN="http://app.doldprod.dealtap.ca/"
			AppFrontEnd_ALPHA="http://app.doldprod.dealtap.ca/"
			POSTGRES_arguments=(HOST USERNAME PASSWORD DBNAME)
			POSTGRES_value=(localhost dealtap dealtap dealtap)
			ConfigRedis_SERVER="localhost"
			ConfigRedis_PORT=6739
			Config_URL_UI="http://app.doldprod.dealtap.ca"
			Config_URL_CORE="http://app.doldprod.dealtap.ca"
			#-------App-core config file argument end----------
			#-------App-ui config file argument start----------
			#ConfigApi_SOURCE=(ApiSource::CORE ApiSource::ANALYTICS)
			ConfigApi_SOURCE=(http://api.doldprod.dealtap.ca/api http://analytics.doldprod.dealtap.ca/api)
			#-------App-ui config file argument end------------

			;;
esac

