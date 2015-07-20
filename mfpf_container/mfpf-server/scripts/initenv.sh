#   Licensed Materials - Property of IBM 
#   5725-I43 (C) Copyright IBM Corp. 2011, 2015. All Rights Reserved.
#   US Government Users Restricted Rights - Use, duplication or
#   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.  
   
#!/usr/bin/bash

usage() 
{
   echo 
   echo " Initializing MobileFirst Platform Foundation on IBM Containers "
   echo " -------------------------------------------------------------- "
   echo " This script creates an environment for building and running IBM MobileFirst Platform Foundation  "
   echo " on the IBM Containers service on Bluemix."
   echo
   echo " Silent Execution (arguments provided as command-line arguments) : "
   echo "   USAGE: initenv.sh <command-line arguments> "
   echo "   command-line arguments: "
   echo "   -a | --api BLUEMIX_API_URL       (Optional) Bluemix API endpoint. Defaults to https://api.ng.bluemix.net"
   echo "   -r | --registry BLUEMIX_REGISTRY (Optional) IBM Containers Registry Host"
   echo "                                      Defaults to registry.ng.bluemix.net"
   echo "   -h | --host BLUEMIX_CCS_HOST     (Optional) IBM Containers Cloud Service Host" 
   echo "                                      Defaults to https://containers-api.ng.bluemix.net/v3/containers"
   echo "   -u | --user BLUEMIX_USER         Bluemix user ID or email address (If not provided, assumes ICE is already logged-in.)"
   echo "   -p | --password BLUEMIX_PASSWORD Bluemix password"
   echo "   -o | --org BLUEMIX_ORG           Bluemix organization"
   echo "   -s | --space BLUEMIX_SPACE       Bluemix space"
   echo
   echo " Silent Execution (arguments loaded from file) : "
   echo "   USAGE: initenv.sh <path to the file from which arguments are read> "
   echo "          See args/initenv.properties for the list of arguments."
   echo 
   echo " Interactive Execution: "
   echo "   USAGE: initenv.sh"
   echo
   exit 1
}

readParams()
{
	  # Read the IBM Bluemix API endpoint
	  #----------------------------------
	  INPUT_MSG="Specify the Bluemix API endpoint. The default value is https://api.ng.bluemix.net (optional) : "
	  ERROR_MSG="Invalid URL. Specify the Bluemix API endpoint. The default value is https://api.ng.bluemix.net (optional) : "
	  DEFAULT_URL="https://api.ng.bluemix.net"
	  BLUEMIX_API_URL=$(fnReadURL "$INPUT_MSG" "$ERROR_MSG" "$DEFAULT_URL")
	
	  # Read the IBM Containers registry host
	  #--------------------------------------
	  read -p "Specify the IBM Containers registry host. The default value is https://registry.ng.bluemix.net (optional) : " BLUEMIX_REGISTRY
	  
	  # Read the IBM Containers Cloud Service host
	  #-------------------------------------------
	  INPUT_MSG="Specify the IBM Containers Cloud Service host. The default value is https://containers-api.ng.bluemix.net/v3/containers (optional) : "
	  ERROR_MSG="Invalid URL. Specify the IBM Containers Cloud Service host. The default value is https://containers-api.ng.bluemix.net/v3/containers (optional) : "
	  DEFAULT_URL="https://containers-api.ng.bluemix.net/v3/containers"
	  BLUEMIX_CCS_HOST=$(fnReadURL "$INPUT_MSG" "$ERROR_MSG" "$DEFAULT_URL")
	
	  # Read the IBM Bluemix User ID or Email    
	  #--------------------------------------
	  INPUT_MSG="Specify your IBM Bluemix user ID or email address (mandatory) : "
	  ERROR_MSG="User ID Field cannot be empty. Specify your IBM Bluemix user ID or email address (mandatory) : "
	  BLUEMIX_USER=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")
	      
	  # Read the IBM Bluemix Password
	  #------------------------------
	  INPUT_MSG="Specify your IBM Bluemix password (mandatory) : "
	  ERROR_MSG="`echo $'\n'`Password cannot be empty. Specify your IBM Bluemix password (mandatory) : "
	  BLUEMIX_PASSWORD=$(fnReadPassword "$INPUT_MSG" "$ERROR_MSG")
	  echo ""
		
	  # Read the IBM Bluemix Organization
	  #----------------------------------
	  INPUT_MSG="Specify your IBM Bluemix organization (mandatory) : "
	  ERROR_MSG="Organization cannot be empty. Specify your IBM Bluemix organization (mandatory) : "
	  BLUEMIX_ORG=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")
	
	  # Read the IBM Bluemix Space 
	  #---------------------------
	  INPUT_MSG="Specify your IBM Bluemix space (mandatory) : "
	  ERROR_MSG="Bluemix Space field cannot be empty. Specify your IBM Bluemix space (mandatory) : "
	  BLUEMIX_SPACE=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")

}

validateParams() 
{
		if [ -z "$BLUEMIX_API_URL" ]
		then
		    BLUEMIX_API_URL=https://api.ng.bluemix.net
		fi
		
		if [ "$(validateURL $BLUEMIX_API_URL)" = "1" ]
		then
		    echo IBM Bluemix API URL is incorrect. Exiting...
		    exit 0
		fi
		
		if [ -z "$BLUEMIX_REGISTRY" ]
		then
		    BLUEMIX_REGISTRY=registry.ng.bluemix.net
		fi
		
		if [ -z "$BLUEMIX_CCS_HOST" ]
		then
		    BLUEMIX_CCS_HOST=https://containers-api.ng.bluemix.net/v3/containers
		fi
		
		if [ "$(validateURL $BLUEMIX_CCS_HOST)" = "1" ]
		then
		    echo IBM Containers Cloud service host URL is incorrect. Exiting...
		    exit 0
		fi
		
		if [ -z "$BLUEMIX_USER" ]
		then
		    echo IBM Bluemix Email ID/UserID field is empty. A mandatory argument must be specified. Exiting...
		    exit 0
		fi
		
		if [ -z "$BLUEMIX_PASSWORD" ]
		then
		    echo IBM Bluemix Password field is empty. A mandatory argument must be specified. Exiting...
		    exit 0
		fi
		
		if [ -z "$BLUEMIX_ORG" ]
		then
		    echo IBM Bluemix Organization field is empty. A mandatory argument must be specified. Exiting...
		    exit 0
		fi
		
		if [ -z "$BLUEMIX_SPACE" ]
		then
		    echo IBM Bluemix Space field is empty. A mandatory argument must be specified. Exiting...
		    exit 0
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
         -r | --registry)
            BLUEMIX_REGISTRY="$2";
            shift
            ;;
         -h | --host)
            BLUEMIX_CCS_HOST="$2";
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
         *)
            usage
            ;;
      esac
      shift
   done
fi

verifyCLI
validateParams

#main

set -e

echo "Arguments : "
echo "----------- "
echo 
echo "BLUEMIX_API_URL : " $BLUEMIX_API_URL
echo "BLUEMIX_REGISTRY : " $BLUEMIX_REGISTRY
echo "BLUEMIX_CCS_HOST : " $BLUEMIX_CCS_HOST
echo "BLUEMIX_USER : " $BLUEMIX_USER
echo "BLUEMIX_PASSWORD : " XXXXXXXX
echo "BLUEMIX_ORG : " $BLUEMIX_ORG
echo "BLUEMIX_SPACE : " $BLUEMIX_SPACE
echo 

echo "Logging into IBM Containers service on Bluemix.."
ice login -a $BLUEMIX_API_URL -H $BLUEMIX_CCS_HOST -R $BLUEMIX_REGISTRY -u $BLUEMIX_USER -p $BLUEMIX_PASSWORD -o $BLUEMIX_ORG -s $BLUEMIX_SPACE

mfp container login -a $BLUEMIX_API_URL -u $BLUEMIX_USER -p $BLUEMIX_PASSWORD -o $BLUEMIX_ORG -s $BLUEMIX_SPACE
