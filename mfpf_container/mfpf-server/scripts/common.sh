#   Licensed Materials - Property of IBM 
#   5725-I43 (C) Copyright IBM Corp. 2011, 2015. All Rights Reserved.
#   US Government Users Restricted Rights - Use, duplication or
#   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.  
   
#!/usr/bin/bash

set -e
validateArg() 
{
   if [ -z "$1" ]
   then
      echo Mandatory argument must be specified. Exiting...
      exit 0
   fi
}

verifyCLI() 
{
   set +e
   echo ""
   echo "Checking if MobileFirst Containers CLI is installed ..."
   echo ""
   scriptdir="$( dirname "$0" )"
   mfpdocker="$(mfp help container 2>/dev/null)"
   if [ -z "$mfpdocker" ]  
   then
     echo MobileFirst Container CLI Extensions are not installed
     echo Try running "$scriptdir/installcontainercli.sh"
     exit 1   
   fi
   set -e
}

validateURL()
{
        regex='(https|http)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
		if echo "$1"|grep -Eq "$regex";then
		    echo "0"
		else
		    echo "1"
		fi
}

fnReadURL()
{
		trap - SIGINT

        ErrorMsg=$2
        InputMsg=$1
        defaultURL=$3

        while read -p "$InputMsg" READ_URL_STRING
        do
                
		if [ -z "$READ_URL_STRING" ]
                then
                        READ_URL_STRING="$defaultURL"
                        break
                fi

                if [ "$(validateURL $READ_URL_STRING)" = "0" ]
                then
                        break
                fi
                InputMsg="$ErrorMsg"
        done
        echo $READ_URL_STRING
}

fnReadInput()
{
		trap - SIGINT
        
		ErrorMsg=$2
        InputMsg=$1

        while read -p "$InputMsg" READ_INPUT_STRING
        do
                if [ ! -z "$READ_INPUT_STRING" ]
                then
                        break
                fi
                InputMsg="$ErrorMsg"
        done
        echo $READ_INPUT_STRING
}

fnReadPassword(){
        trap "stty echo" 0 1 2 3 15

        ErrorMsg=$2
        InputMsg=$1

        while read -s -p "$InputMsg" READ_INPUT_STRING
        do
                if [ ! -z "$READ_INPUT_STRING" ]
                then
                        break
                fi
                InputMsg="$ErrorMsg"
        done
        echo $READ_INPUT_STRING
}

readDBTypeInputAsOptions()
{
        trap - SIGINT
	
		ErrorMsg=$2
        InputMsg=$1

        while read -p "$InputMsg" READ_INPUT_STRING
        do
            	if [ -z "$READ_INPUT_STRING" ]
                then
                       READ_INPUT_STRING="3"
                fi

                if [ "$READ_INPUT_STRING" = "1" ]
                then
                        OUTPUT_STRING="sqldb"
                        break
                elif [ "$READ_INPUT_STRING" = "2" ]
                then
                        OUTPUT_STRING="cloudantNoSQLDB"
                        break
                fi

                InputMsg="$ErrorMsg"
        done
        echo $OUTPUT_STRING
}

readSQLDBServPlanOptions()
{
        trap - SIGINT 
        
		ErrorMsg=$2
        InputMsg=$1

        while read -p "$InputMsg" READ_INPUT_STRING
        do
                if [ -z "$READ_INPUT_STRING" ]
                then
                       READ_INPUT_STRING="4"
                fi

                if [ "$READ_INPUT_STRING" = "1" ]
                then
                        OUTPUT_STRING="sqldb_small"
                        break
                elif [ "$READ_INPUT_STRING" = "2" ]
                then
                        OUTPUT_STRING="sqldb_free"
                        break
                elif [ "$READ_INPUT_STRING" = "3" ]
                then
                        OUTPUT_STRING="sqldb_premium"
                        break
                fi

                InputMsg="$ErrorMsg"
        done
        echo $OUTPUT_STRING

}

validateDBType()
{
    input=$1
    if [ "$input" = "sqldb" ] || [ "$input" = "cloudantNoSQLDB" ]
    then
        echo "0"
    else
        echo "1"
    fi
}

validateDBServiceOption()
{
	input=$2
	dbtype=$1
	
	if [ "$dbtype" = "sqldb" ]
	then
		if [ "$input" = "sqldb_small" ] || [ "$input" = "sqldb_premium" ] || [ "$input" = "sqldb_free" ]
		then
			echo "0"
		else
			echo "1"
		fi
	elif [ "$dbtype" = "cloudantNoSQLDB" ]
	then
		if [ "$input" = "Shared" ]
		then
			echo "0"
		else
			echo "1"
		fi
	fi
}

valid_ip()
{
      IP=$1	
      TEST=`echo "${IP}." | grep -E "([0-9]{1,3}\.){4}"`

      if [ "$TEST" ]
      then
         echo "$IP" | awk -F. '{
            if ( (($1>=0) && ($1<=255)) &&
                 (($2>=0) && ($2<=255)) &&
                 (($3>=0) && ($3<=255)) &&
                 (($4>=0) && ($4<=255)) ) {
               print("0");
            } else {
               print("1");
            }
         }'
      else
         echo "1"
      fi
}

fnReadIP()
{
		trap - SIGINT
	
		ErrorMsg=$2
        InputMsg=$1

        while read -p "$InputMsg" READ_IP_STRING
        do
            if [ "$(valid_ip $READ_IP_STRING)" = "0" ]
                then
                        break
                fi
                InputMsg="$ErrorMsg"
		done
		echo "$READ_IP_STRING"
		
}

fnReadNumericInput()
{
		trap - SIGINT

    	ErrorMsg=$2
        InputMsg=$1
        defaultCount=$3

        while read -p "$InputMsg" READ_NUMBER_STRING
        do
                if [ -z "$READ_NUMBER_STRING" ]
                then
                        READ_NUMBER_STRING="$defaultCount"
                        break
                fi

                if [ "$(isNumber $READ_NUMBER_STRING)" = "0" ]
                then
                    break
                fi
                InputMsg="$ErrorMsg"
        done
        echo $READ_NUMBER_STRING
 
}

fnReadPort()
{
		trap - SIGINT

    	ErrorMsg=$2
        InputMsg=$1

        while read -p "$InputMsg" READ_NUMBER_STRING
        do
                if [ "$(isNumber $READ_NUMBER_STRING)" = "0" ]
                then
                    break
                fi
                InputMsg="$ErrorMsg"
        done
        echo $READ_NUMBER_STRING
 
}

isNumber()
{
    input=$1
    if [ $input -eq $input 2>/dev/null ]
    then
        echo "0"
    else
        echo "1"
    fi

}

readBoolean(){
        trap - SIGINT

        ErrorMsg=$2
        InputMsg=$1
        defaultValue=$3

        while read -p "$InputMsg" READ_INPUT_OPTION
        do
                if [ -z "$READ_INPUT_OPTION" ]
                then
                        READ_INPUT_OPTION="$defaultValue"
                        break
                fi

                if [ "$(validateBoolean $READ_INPUT_OPTION)" = "0" ]
                then
                    break
                fi
                InputMsg="$ErrorMsg"
        done
        echo $READ_INPUT_OPTION
}

validateBoolean()
{
        input=$1

        if [ "$input" = "Y" ] || [ "$input" = "y" ] || [ "$input" = "N" ] || [ "$input" = "n" ]
        then
                echo "0"
        else
                echo "1"
        fi

}










