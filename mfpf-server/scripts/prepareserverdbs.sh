#   Licensed Materials - Property of IBM 
#   5725-I43 (C) Copyright IBM Corp. 2011, 2015. All Rights Reserved.
#   US Government Users Restricted Rights - Use, duplication or
#   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.  
   
#!/usr/bin/bash

usage() 
{
   echo 
   echo " Prepare server databases"
   echo " ------------------------- "
   echo " Use this script to configure the admin / runtime databases. The script is to be run"
   echo " individually for each admin / runtime "
   echo
   echo " Silent Execution (arguments provided as command line arguments):"
   echo "   USAGE: prepareserverdbs.sh <command line arguments> "
   echo "   command-line arguments: "
   echo "     -t | --type DB_TYPE               Bluemix DB service type. (sqldb | cloudantNoSQLDB)"
   echo "     -n | --name DB_SRV_NAME           Bluemix DB service instance name"
   echo "     -pl | --plan DB_SRV_PLAN          Bluemix database service plan."
   echo "                                         For SQL DB, the accepted values are (sqldb_small | sqldb_free | sqldb_premium)"
   echo "                                         For Cloudant DB, the accepted values are (Shared)"
   echo "     -an | --appname APP_NAME          Bluemix application name"
   echo "     -r | --runtime RUNTIME_NAME       (Optional) MFP runtime name. Specified only for configuring runtime database"
   echo "     -sn | --schema SCHEMA_NAME        (Optional) Database schema name. Defaults to WLADMIN for admin database and "
   echo "                                         runtime name for runtime database"
   echo 
   echo " Silent Execution (arguments loaded from file):"
   echo "   USAGE: prepareserverdbs.sh <path to the file from which arguments are read>"
   echo "          Refer to args/prepareserverdbs.properties for the list of arguments"
   echo 
   echo " Interactive Execution: "
   echo "   USAGE: prepareserverdbs.sh"
   echo
   exit 1
}

readParams()
{
    
        # Read the IBM Bluemix Database Type
        #-----------------------------------

        INPUT_MSG="Choose your IBM Bluemix Database Type. Enter 1 or 2 (mandatory).`echo $'\n1. sqldb ' $'\n2. cloudantNoSQLDB ' $'\n' $'\nDBtype>'`"
        ERROR_MSG="Incorrect option. Choose your IBM Bluemix Database Type. Enter 1 or 2 (mandatory). `echo $'\n1. sqldb ' $'\n2. cloudantNoSQLDB ' $'\n' $'\nDBtype> '`"
        DB_TYPE=$(readDBTypeInputAsOptions "$INPUT_MSG" "$ERROR_MSG")
    
        # Read the IBM Bluemix Database Service Name.
        #--------------------------------------------
    	INPUT_MSG="Specify your IBM Bluemix Database Service Name. (mandatory) : "
        ERROR_MSG="Bluemix Database Service Name cannot be empty. Specify your IBM Bluemix Database Service Name. (mandatory) : "
        DB_SRV_NAME=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")

        # Read the IBM Bluemix Database Service Plan.
        #--------------------------------------------
        if [ "$DB_TYPE" = "sqldb" ]
        then
            INPUT_MSG="Choose your IBM Bluemix Database Service Plan for $DB_TYPE. Enter 1, 2 or 3 (mandatory).`echo $'\n1. sqldb_small ' $'\n2. sqldb_free ' $'\n3. sqldb_premium ' $'\n' $'\nDBServicePlan>'`"
            ERROR_MSG="Incorrect option. Choose your IBM Bluemix Database Service Plan for $DB_TYPE. Enter 1, 2 or 3 (mandatory).`echo $'\n1. sqldb_small ' $'\n2. sqldb_free ' $'\n3. sqldb_premium ' $'\n' $'\nDBServicePlan>'`"
            DB_SRV_PLAN=$(readSQLDBServPlanOptions "$INPUT_MSG" "$ERROR_MSG")
        else
            DB_SRV_PLAN="Shared"
        fi
   
        # Read the IBM Bluemix Application Name
        #--------------------------------------
        INPUT_MSG="Specify your IBM Bluemix Application Name (mandatory) : "
        ERROR_MSG="IBM Bluemix Application Name cannot be empty. Specify your IBM Bluemix Application Name (mandatory) : "
        APP_NAME=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")
 
        # Read the Runtime / Project Name
        #-------------------------------
        read -p "Specify your Runtime / Project Name. If not specified assumed to be for admin DB (optional) : " RUNTIME_NAME
 
        # Read the Database Schema Name 
        #---------------------------------
        read -p "Specify your Database Schema Name. Defaults to WLADMIN for admin database and runtime name for runtime database (optional) : " SCHEMA_NAME
    
}

validateParams() 
{
	if [ -z "$BLUEMIX_API_URL" ]
	then
		BLUEMIX_API_URL=https://api.ng.bluemix.net
	fi

	if [ -z "$DB_TYPE" ]
	then
    	echo IBM Bluemix Database Type Field is empty. A mandatory argument must be specified. Exiting...
		exit 0
	fi
	
	if [ "$(validateDBType $DB_TYPE)" = "1" ]
    then
        echo  IBM Bluemix Database Type is invalid. Exiting...
	    exit 0
    fi
	
	if [ -z "$DB_SRV_NAME" ]
	then
    		echo IBM Bluemix Database Service Name Field is empty. A mandatory argument must be specified. Exiting...
			exit 0
	fi
	
	if [ -z "$DB_SRV_PLAN" ]
	then
    		echo IBM Bluemix Database Service Plan Field is empty. A mandatory argument must be specified. Exiting...
			exit 0
	fi
	
	if [ "$(validateDBServiceOption $DB_TYPE $DB_SRV_PLAN)" = "1" ]
    then
        echo  IBM Bluemix Database Service Plan chosen for the Database Type - $DB_TYPE is invalid. Exiting...
	    exit 0
    fi
	
	if [ -z "$APP_NAME" ]
	then
    		echo IBM Bluemix App Name Field is empty. A mandatory argument must be specified. Exiting...
			exit 0
	fi
	
   if [ -z "$RUNTIME_NAME" ]
   then
   	 if [ -z "$SCHEMA_NAME" ]
   	 then
   	 	SCHEMA_NAME=WLADMIN
   	 fi
   else
   	 if [ -z "$SCHEMA_NAME" ]
   	 then
   	 	SCHEMA_NAME=$RUNTIME_NAME
   	 fi
   fi
}

cd "$( dirname "$0" )"

source ./common.sh

if [ $# == 0 ]
then
   readParams
elif [ "$#" -eq 1 -a -f "$1" ]
then
   source "$1"
elif [ "$1" = "-h" -o "$1" = "--help" ]
then
   usage
else
   while [ $# -gt 0 ]; do
      case "$1" in
         -a | --api)
            BLUEMIX_API_URL="$2";
            shift
            ;;
         -u | --user)
            BLUEMIX_USER="$2";
            shift
            ;;
         -p | --password)
            BLUEMIX_PASSWORD="$2";
            shift
            ;;
         -o | --org)
            BLUEMIX_ORG="$2";
            shift
            ;;
         -s | --space)
            BLUEMIX_SPACE="$2";
            shift
            ;;
         -t | --type)
            DB_TYPE="$2";
            shift
            ;;
         -n | --name)
            DB_SRV_NAME="$2";
            shift
            ;;
         -pl | --plan)
            DB_SRV_PLAN="$2";
            shift
            ;;
         -an | --appname)
            APP_NAME="$2";
            shift
            ;;
         -r | --runtime)
            RUNTIME_NAME="$2";
            shift
            ;;
         -sn | --schema)
            SCHEMA_NAME="$2";
            shift
            ;;
         *)
            usage
            ;;
      esac
      shift
   done
fi

trap - SIGINT

validateParams

#main

set -e
echo "Arguments : "
echo "----------- "
echo
echo "DB_TYPE : " $DB_TYPE
echo "DB_SRV_NAME : " $DB_SRV_NAME
echo "DB_SRV_PLAN : " $DB_SRV_PLAN
echo "APP_NAME : " $APP_NAME
echo "RUNTIME_NAME : " $RUNTIME_NAME
echo "SCHEMA_NAME : " $SCHEMA_NAME
echo 

if [ -z $RUNTIME_NAME ]
then
	mfp container configdb -t $DB_TYPE -n $DB_SRV_NAME -p $DB_SRV_PLAN -a $APP_NAME -s $SCHEMA_NAME -f ../usr/config
else
	mfp container configdb -t $DB_TYPE -n $DB_SRV_NAME -p $DB_SRV_PLAN -a $APP_NAME -s $SCHEMA_NAME -r $RUNTIME_NAME -f ../usr/config
fi

