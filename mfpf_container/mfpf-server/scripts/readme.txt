All scripts in the /scripts folder support the following methods for passing-in the required parameters: 
1. Command-line arguments 
2. From file (See args/ folder for related .properties files)
3. Interactively when you run the script with no arguments.

The usage / help of every script can be obtained by using the -h or --help command line arguments

Step 1: initenv.sh - The script logs into the ICE. The script is a prerequisite to run any of the following scripts

Step 2: Server
prepareserverdbs.sh - The script will have to be run once for Admin database and once for every runtime / project
prepareserver.sh - The script will build the sever image with the customizations done to the 'mfpf-server' and pushes the image to the IBM Containers Service.
startserver.sh / startservergroup.sh - Run the script startserver.sh to run the server image as a StandAlone container or startservergroup.sh to run the server image as a container group
