#!/bin/bash
#####################################################################################
#remove the app core
function rm-ui-core
	{
		if [ ! -z ${DTPATH} ];then
			if [ -e ${DTPATH}/app-ui ]
				then
					cd ${DTPATH}
					rm -rf app-ui
					if [ $? -eq 0 ]
						then
							echo "" >/dev/null
					else 
						return 1
					fi
			else 
				echo "project app-ui no found"
			fi
			if [ -e ${DTPATH}/app-core ]
				then
					cd ${DTPATH}/app-core && rm -rf `ls . | egrep -v 'data'`
					if [ $? -eq 0 ]
						then
							echo "" >/dev/null
					else 
						return 1
					fi
			else 
				echo "project app-core no found"
				return 10
			fi
		else
			echo "Home directory no found"
			return 1
		fi
	}
#####################################################################################
#rollback the app core	
function rollback 
{	
	if [ ! -z ${DTPATH} ];then
		cd ${DTPATH}
		if [ -e ./app-ui.tar.gz -a -e ./app-core.tar.gz ];then
			tar zxf app-ui.tar.gz && tar zxf app-core.tar.gz --exclude=app-core/data
			if [ $? -ne 0 ];then
				return 1
			fi
		fi
		rm -rf app-ui.tar.gz
		rm -rf app-core.tar.gz				
	else
		echo "Home directory no found"
		return 1
	fi


}
###################################################################################
#Output running state
function echo-status
	{	
		echo "=====================$1 start $(date +%T)===================="
		$1
		is=$?
		if [ $is -eq 0 ];then
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