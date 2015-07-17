#   Licensed Materials - Property of IBM 
#   5725-I43 (C) Copyright IBM Corp. 2011, 2015. All Rights Reserved.
#   US Government Users Restricted Rights - Use, duplication or
#   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.  

#!/usr/bin/bash

usage() 
{
   echo 
   echo " Preparing the MobileFirst Operational Analytics image "
   echo " ----------------------------------------------------- "
   echo " This script loads, customizes, tags, and pushes the MobileFirst Operational"
   echo " Analytics image on the IBM Containers service on Bluemix."
   echo " Prerequisite: You must run the initenv.sh script before running this script."
   echo
   echo " Silent Execution (arguments provided as command line arguments): "
   echo "   USAGE: prepareanalytics.sh <command-line arguments> "
   echo "   command-line arguments: "
   echo "     -t | --tag ANALYTICS_IMAGE_TAG  Tag to be used for tagging the analytics image."
   echo "                                     Format: registryUrl/namespace/tag"
   echo
   echo " Silent Execution (arguments loaded from file): "
   echo "   USAGE: prepareanalytics.sh <path to the file from which arguments are read> "
   echo "          See args/prepareanalytics.properties for the list of arguments."
   echo 
   echo " Interactive Execution: "
   echo "   USAGE: prepareanalytics.sh"
   echo
   exit 1
}

readParams()
{
   
   # Read the tag for the analytics image
   #-------------------------------------
   INPUT_MSG="Specify the tag for the analytics image (mandatory) : "
   ERROR_MSG="Tag for analytics image cannot be empty. Specify the tag for the analytics image (mandatory) : "
   ANALYTICS_IMAGE_TAG=$(fnReadInput "$INPUT_MSG" "$ERROR_MSG")
}

validateParams() 
{
		if [ -z "$ANALYTICS_IMAGE_TAG" ]
		then
	    	echo Analytics Image Tag is empty. A mandatory argument must be specified. Exiting...
				exit 0
		fi
}

clean_up() {
	# Perform clean up before exiting
	cd "${absoluteScriptDir}"
        
    if [ -d ../dependencies ]
    then
        mv ../dependencies ../../dependencies
    fi
    if [ -d ../mfpf-libs ]
    then
        mv ../mfpf-libs ../../mfpf-libs
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
         -l | --location)
            ANALYTICS_IMAGE_LOCATION="$2";
            shift
            ;;
         -t | --tag)
            ANALYTICS_IMAGE_TAG="$2";
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
trap clean_up 0 1 2 3 15

scriptDir=`dirname $0`
absoluteScriptDir=`pwd`/${scriptDir}/

echo "Arguments : "
echo "----------- "
echo 
echo "ANALYTICS_IMAGE_TAG : " $ANALYTICS_IMAGE_TAG
echo 

mv ../../dependencies ../dependencies
mv ../../mfpf-libs ../mfpf-libs

addSshToDockerfile ../usr ../Dockerfile
		
echo "Building the analytics image : " $ANALYTICS_IMAGE_TAG
docker build -t $ANALYTICS_IMAGE_TAG ../

mv ../dependencies ../../dependencies
mv ../mfpf-libs ../../mfpf-libs

echo "Pushing the analytics image to IBM Containers registry.."
ice --local push $ANALYTICS_IMAGE_TAG