#   Licensed Materials - Property of IBM 
#   5725-I43 (C) Copyright IBM Corp. 2011, 2015. All Rights Reserved.
#   US Government Users Restricted Rights - Use, duplication or
#   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.  
   
#!/usr/bin/bash

set +e

usage() 
{
   echo 
   echo " Installation Script for deploying MobileFirst Platform Foundation Container Extension commands"
   echo " ----------------------------------------------------------------------------------------------"
   echo " This script is used to deploy IBM MobileFirst Platform Foundation container extension"
   echo " commands into existing Command Line Interface (CLI)"
   echo
   echo "   USAGE: installcontainercli.sh"
   echo
   exit 1
}

if [ "$#" -eq 1 ]
then
  if [ "$1" = "-h" -o "$1" = "--help" ]
  then
    usage
  fi
fi

scriptdir="$( dirname "$0" )"
mfplocation="$(which mfp)"
if [ -z "$mfplocation" ]
then
  echo "MobileFirst Platform CLI is not installed"
  exit 1
fi

mfpversion_output="$(mfp -v)"
mfpversion=`echo $mfpversion_output | cut -c1-3`
if [[ "${mfpversion}" != "7.1" ]]
then
  echo "MobileFirst Platform CLI version is $mfpversion. Install the latest version and retry."
  exit 1
fi

mfpdir="$(dirname $mfplocation)"
nmdir=$mfpdir/mobilefirst-cli/node_modules/

if [ -d $nmdir/mfp-container-cmds ]
then
   echo "Removing the earlier version of MobileFirst CLI Container Extensions"
   rm -rf $nmdir/mfp-container-cmds
fi

echo "Deploying MobileFirst CLI Container Extensions"
mfpdir="$(dirname $mfplocation)"
nmdir=$mfpdir/mobilefirst-cli/node_modules/
unzip -oq $scriptdir/../../mfpf-libs/mfpf-cli-commands.zip -d $nmdir
echo "Done"
set -e
