#/bin/bash
ENVIRONMENT=$1
BACKUP_NAME=$2
case $1 in
	"30QA-older")
		DTPATH=/media/sf_src
		DATABASE=pre_prod
		ANAPATH=/media/sf_src
		ANALYTICS_DATABASE=analytics
		;;
	"30prod-older")
		DTPATH=/media/sf_src
		DATABASE=dealtap
		ANAPATH=/media/sf_src
		ANALYTICS_DATABASE=analytics
		;;
	"test30QA-older")
		DTPATH=/media/sf_src
		DATABASE=pre-prod
		ANAPATH=/media/sf_src
		ANALYTICS_DATABASE=analytics
		;;
	"test30prod-older")
		DTPATH=/media/sf_src
		DATABASE=dealtap
		ANAPATH=/media/sf_src
		ANALYTICS_DATABASE=analytics
		;;
	*)
		echo "please reset"
		exit 1
		;;
esac
