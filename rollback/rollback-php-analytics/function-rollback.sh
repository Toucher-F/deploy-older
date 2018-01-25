#!/bin/bash
############################################################################################
#remove analytics project current core
function rm-analytics
	{	
		
		if [ -e ${ANAPATH}/analytics ]
			then
				cd ${ANAPATH}
				rm -rf analytics
				if [ $? -eq 0 ]
					then
						return 0
				else 
					return 1
				fi
		else
			echo "project analytics no found"
			return 10
		fi	
	}
############################################################################################
#Rollback analytics project backup core
function rollback-analytics 
	{	
		if [ ! -z ${ANAPATH} ]
			then
			if [ -e /${ANAPATH}/analytics.tar.gz ]
				then
					cd ${ANAPATH}
					tar -zxf analytics.tar.gz
					if [ $? -ne 0 ]
					then
						return 1
					fi
					rm -rf analytics.tar.gz
			else
				echo "backup file no found"
				return 1
			fi
		else
			echo "Home directory no found"
			return 1
		fi

	}
############################################################################################
#Output running state
function echo-status
	{	
		echo "=====================$1 start $(date +%T)===================="
		$1
		if [ $? -eq 0 ]
			then
				echo "$1 success"
		else 
			echo "$1 faild"
			sleep 10
			exit 1
		fi
		echo "=====================$1 end $(date +%T)===================="



	}
