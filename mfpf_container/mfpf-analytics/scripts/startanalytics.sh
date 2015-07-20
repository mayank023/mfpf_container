#   Licensed Materials - Property of IBM
#   5725-I43 (C) Copyright IBM Corp. 2011, 2015. All Rights Reserved.
#   US Government Users Restricted Rights - Use, duplication or
#   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

#!/usr/bin/bash

usage()
{
   echo
   echo " Script to run the IBM MobileFirst Operational Analytics Image as a Container "
   echo " -----------------------------------------------------------------------------"
   echo " This script runs the MobileFirst Operational Analytics image as a container"
   echo " on the IBM Containers service on Bluemix."
   echo " Prerequisite: The prepareanalytics.sh script must be run before running this script."
   echo
   echo " Silent Execution (arguments provided as command line arguments): "
   echo "   USAGE: startanalytics.sh <command-line arguments>"
   echo "   command-line arguments: "
   echo "     -t | --tag  ANALYTICS_IMAGE_TAG       Tag for the analytics image"
   echo "     -n | --name ANALYTICS_CONTAINER_NAME  Name of the analytics container"
   echo "     -i | --ip   ANALYTICS_IP              IP address the analytics container should be bound to"
   echo "     -h | --http EXPOSE_HTTP               (Optional) Expose HTTP Port. Accepted values are Y (default) or N"
   echo "     -s | --https EXPOSE_HTTPS             (Optional) Expose HTTPS Port. Accepted values are Y (default) or N"
   echo "     -m | --memory SERVER_MEM              (Optional) Assign a memory limit to the container in megabytes (MB)"
   echo "                                             Accepted values are 1024 (default), 2048,..."
   echo "     -se | --ssh SSH_ENABLE                (Optional) Enable SSH for the container. Accepted values are Y (default) or N"
   echo "     -sk | --sshkey SSH_KEY                (Optional) SSH Key to be injected into the container"
   echo "     -tr | --trace TRACE_SPEC              (Optional) Trace specification to be applied to MobileFirst Server"
   echo "     -ml | --maxlog MAX_LOG_FILES          (Optional) Maximum number of log files to maintain before overwriting"
   echo "     -ms | --maxlogsize MAX_LOG_FILE_SIZE  (Optional) Maximum size of a log file"
   echo "     -v | --volume ENABLE_VOLUME           (Optional) Enable mounting volume for container logs. Accepted values are Y or N (default)"
   echo "     -ev | --enabledatavolume ENABLE_ANALYTICS_DATA_VOLUME       (Optional) Enable mounting volume for analytics data. Accepted values are Y or N (default)"
   echo "     -av | --datavolumename ANALYTICS_DATA_VOLUME_NAME           (Optional) Specify name of the volume to be created and mounted for analytics data. Default value is mfpf_analytics_<ANALYTICS_CONTAINER_NAME>"
   echo "     -ad | --analyticsdatadirectory ANALYTICS_DATA_DIRECTORY     (Optional) Specify the directory to be used for storing analytics data. Default value is /analyticsData"
   echo "     -e | --env MFPF_PROPERTIES            (Optional) Provide related MobileFirst Operational Analytics image properties as comma-separated"
   echo "                                             key:value pairs. Example: serviceContext:analytics-service"
   echo
   echo " Silent Execution (arguments loaded from file): "
   echo "   USAGE: startanalytics.sh <path to the file from which arguments are read>"
   echo "          See args/startanalytics.properties for the list of arguments."
   echo
   echo " Interactive Execution: "
   echo "   USAGE: startanalytics.sh"
   echo
   exit 1
}

readParams()
{

   # Read the tag for the MobileFirst Operational Analytics image 
   #-------------------------------------------------------------
   INPUT_MSG="Specify the tag for the analytics image. Should be of form registryUrl/repositoryNamespace/tag (mandatory) : "
   ERROR_MSG="Tag for analytics image cannot be empty. Specify the tag for the analytics image. Should be of form registryUrl/repositoryNamespace/tag (mandatory) : "
   ANALYTICS_IMAGE_TAG=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")

   # Read the name of the MobileFirst Operational Analytics container  
   #-----------------------------------------------------------------
   INPUT_MSG="Specify the name for the analytics container (mandatory) : "
   ERROR_MSG="Analytics Container name cannot be empty. Specify the name for the analytics container (mandatory) : "
   ANALYTICS_CONTAINER_NAME=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")

   # Read the IP for the MobileFirst Operational Analytics container 
   #----------------------------------------------------------------
   INPUT_MSG="Specify the IP address for the analytics container (mandatory) : "
   ERROR_MSG="Incorrect IP Address. Specify a valid IP address for the analytics container (mandatory) : "
   ANALYTICS_IP=$(fnReadIP "$INPUT_MSG" "$ERROR_MSG")

   # Expose HTTP/HTTPS Port 
   #-----------------------
   INPUT_MSG="Expose HTTP Port. Accepted values are Y or N. The default value is Y. (optional) : "
   ERROR_MSG="Input should be either Y or N. Expose HTTP Port. Accepted values are Y or N. The default value is Y. (optional) : "
   EXPOSE_HTTP=$(readBoolean "$INPUT_MSG" "$ERROR_MSG" "Y")

   INPUT_MSG="Expose HTTPS Port. Accepted values are Y or N. The default value is Y. (optional) : "
   ERROR_MSG="Input should be either Y or N. Expose HTTPS Port. Accepted values are Y or N. The default value is Y. (optional) : "
   EXPOSE_HTTPS=$(readBoolean "$INPUT_MSG" "$ERROR_MSG" "Y")

   # Read the memory for the server container 
   #-----------------------------------------
   INPUT_MSG="Specify the memory size limit (in MB) for the server container. Accepted values are 1024, 2048,.... The default value is 1024 MB. (optional) : "
   ERROR_MSG="Error due to non-numeric input. Specify a valid number (in MB) for the memory size limit. Valid values are 1024, 2048,... The default value is 1024 MB (optional) : "
   SERVER_MEM=$(fnReadNumericInput "$INPUT_MSG" "$ERROR_MSG" "1024")

   # Read the SSH details  
   #---------------------
   INPUT_MSG="Enable SSH For the server container. Accepted values are Y or N. The default value is Y. (optional) : " 
   ERROR_MSG="Input should be either Y or N. Enable SSH For the server container. Accepted values are Y or N. The default value is Y. (optional) : "
   SSH_ENABLE=$(readBoolean "$INPUT_MSG" "$ERROR_MSG" "Y")

   # Read the SSH details
   #---------------------
   if [ "$SSH_ENABLE" = "Y" ] || [ "$SSH_ENABLE" = "y" ]
   then
      read -p "Provide an SSH Key to be injected into the container. Provide the contents of your id_rsa.pub file (optional): " SSH_KEY
   fi

   # Read the Mounting Volume for server Data
   #------------------------------------------
   INPUT_MSG="Enable mounting volume for the server container logs. Accepted values are Y or N. The default value is N. (optional) : "
   ERROR_MSG="Input should be either Y or N. Enable mounting volume for the server container logs. Accepted values are Y or N. The default value is N. (optional) : " 
   ENABLE_VOLUME=$(readBoolean "$INPUT_MSG" "$ERROR_MSG" "N")

   # Read the Mounting Volume for Analytics Data details  
   #----------------------------------------------------
   INPUT_MSG="Enable mounting volume for analytics data. Accepted values are Y or N. The default value is N. (optional) : "
   ERROR_MSG="Input should be either Y or N. Enable mounting volume for analytics data. Accepted values are Y or N. The default value is N. (optional) : "
   ENABLE_ANALYTICS_DATA_VOLUME=$(readBoolean "$INPUT_MSG" "$ERROR_MSG" "N")

   if [ "$ENABLE_ANALYTICS_DATA_VOLUME" = "Y" ] || [ "$ENABLE_ANALYTICS_DATA_VOLUME" = "y" ]
   then   
       read -p "Specify name of the volume to be created and mounted for analytics data. Default value is mfpf_analytics_<ANALYTICS_CONTAINER_NAME> (optional) : " ANALYTICS_DATA_VOLUME_NAME
   fi
   
   read -p "Specify the directory to be used for storing analytics data. The default value is /analyticsData (optional) : " ANALYTICS_DATA_DIRECTORY

   # Read the Trace details  
   #-----------------------  
   read -p "Provide the Trace specification to be applied to the MobileFirst Server. The default value is *=info (optional): " TRACE_SPEC

   # Read the maximum number of log files 
   #-------------------------------------
   INPUT_MSG="Provide the maximum number of log files to maintain before overwriting them. The default value is 5 files. (optional): "
   ERROR_MSG="Error due to non-numeric input. Provide the maximum number of log files to maintain before overwriting them. The default value is 5 files. (optional): "
   MAX_LOG_FILES=$(fnReadNumericInput "$INPUT_MSG" "$ERROR_MSG" "5")

   # Maximum size of a log file in MB 
   #----------------------------------
   INPUT_MSG="Maximum size of a log file (in MB). The default value is 20 MB. (optional): "
   ERROR_MSG="Error due to non-numeric input. Specify a number to represent the maximum log file size (in MB) allowed. The default value is 20 MB. (optional): "
   MAX_LOG_FILE_SIZE=$(fnReadNumericInput "$INPUT_MSG" "$ERROR_MSG" "20")

   # Specify the MFP related properties  
   #-----------------------------------   
   read -p "Specify related MobileFirst Operational Analytics properties as comma-separated key:value pairs (optional) : "

}

validateParams()
{

	if [ -z "$ANALYTICS_IMAGE_TAG" ]
	then
    		echo Analytics Image Tag is empty. A mandatory argument must be specified. Exiting...
			exit 0
	fi
	
	if [ -z "$ANALYTICS_CONTAINER_NAME" ]
	then
    		echo Analytics Container Name is empty. A mandatory argument must be specified. Exiting...
			exit 0
	fi

	if [ -z "$ANALYTICS_IP" ]
	then
    		echo Analytics Container IP Address field is empty. A mandatory argument must be specified. Exiting...
			exit 0
	fi
	
	if [ "$(valid_ip $ANALYTICS_IP)" = "1" ]
	then
		    echo Analytics Container IP Address is incorrect. Exiting...
	        exit 0
	fi

   if [ -z "$SERVER_MEM" ]
   then
      SERVER_MEM=1024
   fi

	if [ "$(isNumber $SERVER_MEM)" = "1" ]
    then
        echo  Required Analytics Container Memory must be a Number. Exiting...
	    exit 0
    fi

   if [ -z "$SSH_ENABLE" ]
   then
     SSH_ENABLE=Y
   fi

	if [ "$(validateBoolean $SSH_ENABLE)" = "1" ]
    then
        echo  Invalid Value for SSH_ENABLE. Values must be either Y / N. Exiting...
	    exit 0
    fi

   if [ -z "$ENABLE_VOLUME" ]
   then 
      ENABLE_VOLUME=N
   fi

	if [ "$(validateBoolean $ENABLE_VOLUME)" = "1" ]
    then
        echo  Invalid Value for ENABLE_VOLUME. Values must be either Y / N. Exiting...
	    exit 0
    fi

   if [ -z "$ENABLE_ANALYTICS_DATA_VOLUME" ]
   then
      ENABLE_ANALYTICS_DATA_VOLUME=N
   fi   

	if [ "$(validateBoolean $ENABLE_ANALYTICS_DATA_VOLUME)" = "1" ]
    then
        echo  Invalid Value for ENABLE_ANALYTICS_DATA_VOLUME. Values must be either Y / N. Exiting...
	    exit 0
    fi
   
   if [ -z "$ANALYTICS_DATA_VOLUME_NAME" ]
   then
      ANALYTICS_DATA_VOLUME_NAME=mfpf_analytics_$ANALYTICS_CONTAINER_NAME
   fi   
    
   if [ -z "$ANALYTICS_DATA_DIRECTORY" ]
   then
      ANALYTICS_DATA_DIRECTORY=/analyticsData
   fi  
   
   if [ -z "$EXPOSE_HTTP" ]
   then
      EXPOSE_HTTP=Y
   fi

	if [ "$(validateBoolean $EXPOSE_HTTP)" = "1" ]
    then
        echo  Invalid Value for EXPOSE_HTTP. Values must be either Y / N. Exiting...
	    exit 0
    fi

   if [ -z "$EXPOSE_HTTPS" ]
   then
      EXPOSE_HTTPS=Y
   fi

	if [ "$(validateBoolean $EXPOSE_HTTPS)" = "1" ]
    then
        echo  Invalid Value for EXPOSE_HTTPS. Values must either Y / N. Exiting...
	    exit 0
    fi
}

createDataVolume()
{
   volume_exists="False"
   volumes="$(ice volume list)"
   if [ ! -z "${volumes}" ]
   then
      for oneVolume in ${volumes}
      do
         if [[ "${oneVolume}" = "${ANALYTICS_DATA_VOLUME_NAME}" ]]
         then
            volume_exists="True"
            break
         fi
      done
   fi
   if [[ "${volume_exists}" = "True" ]]
   then
      echo "Volume already exists: $ANALYTICS_DATA_VOLUME_NAME. This volume will be used to store analytics data."
   else
      echo "The volume $ANALYTICS_DATA_VOLUME_NAME will be created to store analytics data."
      eval "ice volume create $ANALYTICS_DATA_VOLUME_NAME"
   fi
}

createVolumes() 
{
  echo "Creating volumes"
  
  sysvol_exist="False"
  libertyvol_exist="False"
  
  volumes="$(ice volume list)"

  if [ ! -z "${volumes}" ]
   then
      for mVar in ${volumes}
      do
         if [[ "$mVar" = "$SYSVOL_NAME" ]]
         then
            sysvol_exist="True"
            continue
         elif [[ "$mVar" = "$LIBERTYVOL_NAME" ]]
         then
           libertyvol_exist="True"
         fi
      done
   fi

   if [[ "$sysvol_exist" = "True" ]]
   then
      echo "Volume already exists: $SYSVOL_NAME. This volume will be used to store sys logs."
   else
      echo "The volume $SYSVOL_NAME will be created to store sys logs."
      eval "ice volume create $SYSVOL_NAME"
   fi
   
   if [[ "$libertyvol_exist" = "True" ]]
   then
      echo "Volume already exists: $LIBERTYVOL_NAME. This volume will be used to store Liberty logs."
   else
      echo "The volume $LIBERTYVOL_NAME will be created to store Liberty logs."
      eval "ice volume create $LIBERTYVOL_NAME"
   fi
}

#INIT
# The volume name and the path in the container that the volume will be mounted
SYSVOL_NAME=sysvol
LIBERTYVOL_NAME=libertyvol
SYSVOL_PATH=/var/log/rsyslog
LIBERTYVOL_PATH=/opt/ibm/wlp/usr/servers/worklight/logs

cd "$( dirname "$0" )"

source ./common.sh
source ../usr/env/server.env

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
         -t | --tag)
            ANALYTICS_IMAGE_TAG="$2";
            shift
            ;;
         -n | --name)
            ANALYTICS_CONTAINER_NAME="$2";
            shift
            ;;
         -i | --ip)
            ANALYTICS_IP="$2";
            shift
            ;;
         -se | --ssh)
            SSH_ENABLE="$2";
            shift
            ;;
       	 -v | --volume)
            ENABLE_VOLUME="$2";
            shift
            ;;
         -ev | --enabledatavolume)
            ENABLE_ANALYTICS_DATA_VOLUME="$2";
            shift
            ;;   
         -av | --datavolumename)
            ANALYTICS_DATA_VOLUME_NAME="$2";
            shift
            ;; 
         -ad | --analyticsdatadirectory)
            ANALYTICS_DATA_DIRECTORY="$2";
            shift
            ;;  
         -h | --http)
            EXPOSE_HTTP="$2";
            shift
            ;;
         -s | --https)
            EXPOSE_HTTPS="$2";
            shift
            ;;
         -m | --memory)
            SERVER_MEM="$2";
            shift
            ;;
         -e | --env)
            MFPF_PROPERTIES="$2";
            shift
            ;;
         -sk | --sshkey)
            SSH_KEY="$2";
            shift
            ;;
         -tr | --trace)
            TRACE_SPEC="$2";
            shift
            ;;
         -ml | --maxlog)
            MAX_LOG_FILES="$2";
            shift
            ;;
         -ms | --maxlogsize)
            MAX_LOG_FILE_SIZE="$2";
            shift
            ;;
         *)
            usage
            ;;
      esac
      shift
   done
fi

validateParams

#main

set -e

echo "Arguments : "
echo "----------- "
echo
echo "ANALYTICS_IMAGE_TAG : " $ANALYTICS_IMAGE_TAG
echo "ANALYTICS_CONTAINER_NAME : " $ANALYTICS_CONTAINER_NAME
echo "ANALYTICS_IP : " $ANALYTICS_IP
echo "SSH_ENABLE : " $SSH_ENABLE
echo "ENABLE_VOLUME : " $ENABLE_VOLUME
echo "ENABLE_ANALYTICS_DATA_VOLUME : " $ENABLE_ANALYTICS_DATA_VOLUME
echo "ANALYTICS_DATA_VOLUME_NAME : " $ANALYTICS_DATA_VOLUME_NAME
echo "ANALYTICS_DATA_DIRECTORY : " $ANALYTICS_DATA_DIRECTORY
echo "EXPOSE_HTTP : " $EXPOSE_HTTP
echo "EXPOSE_HTTPS : " $EXPOSE_HTTPS
echo "SERVER_MEM : " $SERVER_MEM
echo "SSH_KEY : " $SSH_KEY
echo "TRACE_SPEC : " $TRACE_SPEC
echo "MAX_LOG_FILES : " $MAX_LOG_FILES
echo "MAX_LOG_FILE_SIZE : " $MAX_LOG_FILE_SIZE
echo "MFPF_PROPERTIES : " $MFPF_PROPERTIES
echo

icecmd="ice run $ANALYTICS_IMAGE_TAG -n $ANALYTICS_CONTAINER_NAME -m $SERVER_MEM -p 9500"
if [ "$SSH_ENABLE" = "Y" ] || [ "$SSH_ENABLE" = "y" ]
then
   icecmd="$icecmd -p 22"
fi

if [ "$ENABLE_VOLUME" = "Y" ] || [ "$ENABLE_VOLUME" = "y" ]
then
   createVolumes
   icecmd="$icecmd -v $SYSVOL_NAME:$SYSVOL_PATH"
   icecmd="$icecmd -v $LIBERTYVOL_NAME:$LIBERTYVOL_PATH"
   icecmd="$icecmd --env LOG_LOCATIONS=$SYSVOL_PATH/syslog,$LIBERTYVOL_PATH/messages.log,$LIBERTYVOL_PATH/console.log,$LIBERTYVOL_PATH/trace.log"
fi

if [ "$ENABLE_ANALYTICS_DATA_VOLUME" = "Y" ] || [ "$ENABLE_ANALYTICS_DATA_VOLUME" = "y" ]
then
   createDataVolume
   icecmd="$icecmd -v $ANALYTICS_DATA_VOLUME_NAME:$ANALYTICS_DATA_DIRECTORY -e ANALYTICS_DATA_DIRECTORY=$ANALYTICS_DATA_DIRECTORY  "
else
   icecmd="$icecmd -e ANALYTICS_DATA_DIRECTORY=$ANALYTICS_DATA_DIRECTORY  "
fi

if [ "$EXPOSE_HTTP" = "Y" ] || [ "$EXPOSE_HTTP" = "y" ]
then
   icecmd="$icecmd -p $ANALYTICS_HTTPPORT"
fi

if [ "$EXPOSE_HTTPS" = "Y" ] || [ "$EXPOSE_HTTPS" = "y" ]
then
   icecmd="$icecmd -p $ANALYTICS_HTTPSPORT"
fi

if [ ! -z "$MFPF_PROPERTIES" ]
then
   icecmd="$icecmd -e mfpfproperties=$MFPF_PROPERTIES"
fi

if [ ! -z "$SSH_KEY" ] && ([ "$SSH_ENABLE" = "Y" ] || [ "$SSH_ENABLE" = "y" ])
then
   icecmd="$icecmd -k \"$SSH_KEY\""
fi

if [ -z "$TRACE_SPEC" ]
then
   TRACE_SPEC="*=info"
fi

if [ -z "$MAX_LOG_FILES" ]
then
   MAX_LOG_FILES="5"
fi

if [ -z "$MAX_LOG_FILE_SIZE" ]
then
   MAX_LOG_FILE_SIZE="20"
fi

TRACE_SPEC=${TRACE_SPEC//"="/"~"}

icecmd="$icecmd -e ANALYTICS_TRACE_LEVEL=$TRACE_SPEC -e ANALYTICS_MAX_LOG_FILES=$MAX_LOG_FILES -e ANALYTICS_MAX_LOG_FILE_SIZE=$MAX_LOG_FILE_SIZE"

echo "Starting the analytics container : " $ANALYTICS_CONTAINER_NAME
echo "Executing command : " $icecmd

ICE_RUN_RESULT=`eval ${icecmd}; echo $?`
echo "$ICE_RUN_RESULT"

GREPPED_RESULT=$(echo $ICE_RUN_RESULT | grep -i "Failed" | wc -l | tr -s " ")

if [ $(echo $GREPPED_RESULT) != "0" ]
then
        echo "ERROR: ice run command failed. Exiting ..."
        exit 1
fi

ANALYTICS_CONTAINER_ID=`echo $ICE_RUN_RESULT | cut -f1 -d " "`

set -e
echo "Checking the status of the Container  - $ANALYTICS_CONTAINER_ID ..."
COUNTER=40
while [ $COUNTER -gt 0 ]
do
        ICE_RUN_CONTAINER_STATE=$(echo $(ice ps | grep $ANALYTICS_CONTAINER_ID | grep -Ei 'BUILD|Running' | wc -l ))
        if [ $(echo $ICE_RUN_CONTAINER_STATE) = "1" ]
        then
                break
        fi

        # Allow to container group to come up
        sleep 5s

        COUNTER=`expr $COUNTER - 1`
done


if [ $(echo $ICE_RUN_CONTAINER_STATE) != "1" ]
then
        echo "ERROR: Analytics container is not in either a BUILD or RUNNING state. Binding an IP address to a container is not possible. Exiting..."
        echo "INFO: To bind manually run the command : ice ip bind $ANALYTICS_IP $ANALYTICS_CONTAINER_NAME"
        exit 1
fi

echo "Binding the analytics container to IP : " $ANALYTICS_IP
ice ip bind $ANALYTICS_IP $ANALYTICS_CONTAINER_NAME

set +e
