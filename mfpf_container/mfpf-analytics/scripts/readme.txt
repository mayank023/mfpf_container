All the scripts in the /scripts folder support the following methods for passing-in the required parameters: 
1. Command-line arguments 
2. From file (See args/ folder for related .properties files)
3. Interactively when you run the script with no arguments.

The usage / help of every script can be obtained by using the -h or --help command line arguments

Step 1: initenv.sh - The script logs into the ICE. The script is a prerequisite to run any of the following scripts

Step 2: Analytics
prepareanalytics.sh - The script will build the analytics image with the customizations done to the 'mfpf-analytics' and pushes the image to the IBM Containers Service.
startanalytics.sh / startanalyticsgroup.sh - Run the script startanalytics.sh to run the analytics image as a StandAlone container or startanalyticsgroup.sh to run the analytics image as a container group
