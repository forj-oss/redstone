#!/bin/bash

# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Define fortify sca (see puppet manifest for installation of fortify sca) 
FORTIFY_BASE=/opt/fortify/
SCA_BIN=$FORTIFY_BASE/bin/sourceanalyzer

GREP=/bin/grep

#note these tokens are found in the sca scan text output, naturally if those change
#these have to be changed

LOW="low :"
MED="medium :"
HIGH="high :"
CRIT="critical :"

# default
DEFAULT_LOW_THRESHOLD=100
DEFAULT_MED_THRESHOLD=50
DEFAULT_HIGH_THRESHOLD=20
DEFAULT_CRIT_THRESHOLD=1


usage()
{
cat <<EOF

usage: $0 options


OPTIONS:
   -v    Show this message

EOF
}

# make sure we do not allow below minimum threshold 
check-min()
{
 if [ $1 -lt $2 ]; then
     echo $2
 else
    echo $1
 fi
}
# exec wrapper
do_cmd()
{
      "$@"
      ret=$?
      if [[ $ret -eq 0 ]]
      then
        echo "Successfully ran [ $@ ]"
      else
        echo "Error: Command [ $@ ] returned $ret"
        return $ret
      fi
}



## Main ###

if [ $# -eq 0 ] ; then
   usage 
   exit 1 
fi

while getopts ":vl:m:c:t:b:d" OPTION
do
     case $OPTION in
         v)
             usage
             exit 1
             ;;


         b)  scan_id=$OPTARG
             ;;
         l)
             low_threshold=$(check-min $OPTARG $DEFAULT_LOW_THRESHOLD)
             ;;
         m) 
             med_threshold=$(check-min $OPTARG $DEFAULT_MED_THRESHOLD)
             ;;

         h)
             high_threshold=$(check-min $OPTARG $DEFAULT_HIGH_THRESHOLD)
             ;;
         c)
             crit_threshold=$(check-min $OPTARG $DEFAULT_CRIT_THRESHOLD)
             ;;

         d) # use defaults 
            low_threshold=$DEFAULT_LOW_THRESHOLD
            med_threshold=$DEFAULT_MED_THRESHOLD
            high_threshold=$DEFAULT_HIGH_THRESHOLD
            crit_threshold=$DEFAULT_CRIT_THRESHOLD
            ;;
         t)
            proj_type=$OPTARG
            ;;

         \?)
             echo "Illegal argument $OPTION=$OPTARG" >&2
             usage
             exit 1
             ;;

         :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
     esac
done


# We depend on good 'ol grep so lets check for it... 
if ! type "$GREP" > /dev/null; then
    echo "grep was not found, please install it before proceeding..."
    exit 1
fi

# We depend on fortify source analyzer
if ! type "$SCA_BIN" > /dev/null; then
     echo "fortify sca cli was not found, please install it or set path correctly before proceeding..."
     exit 1
fi


# call scanner depening on project type

scan_log="$scan_id/target/fortify-scan.log"
case $proj_type in
    java-web) 
        echo "cleaning.." > $scan_log
        do_cmd $SCA_BIN -b $scan_id -clean >> $scan_log
        echo "translating.." >> $scan_log
        do_cmd $SCA_BIN -jdk 1.6 -b $scan_id -cp "$scan_id/target/**/*.jar" "$scan_id/target/classes" "$scan_id/src/main/**/*.java" "$scan_id/src/main/**/*.jsp" "$scan_id/src/main/**/*.xml" "$scan_id/src/main/**/*.properties" >> $scan_log
         if [[ ! $? -eq 0 ]]; then
           exit 1
        fi
        echo "scanning.." >> $scan_log
        do_cmd $SCA_BIN -b $scan_id -scan -XX:MaxPermSize=128M >> $scan_log
        if [[ ! $? -eq 0 ]]; then
           exit 1
        fi
        ;;
    *) echo "this project type is not supported"
       exit 1
       ;;
esac

# shred scan log
low=`$GREP -c "$LOW" $scan_log`
med=`$GREP -c "$MED" $scan_log`
high=`$GREP -c "$HIGH" $scan_log`
crit=`$GREP -c "$CRIT" $scan_log`


# Apparently && and || "short-circuit", so lets test critical count first
if [[ $crit -gt $crit_threshold ||  $high -gt $high_threshold || $med -gt $med_threshold || $low -gt $low_threshold ]]
then
    echo "scan failed" >&2
    exit 1
fi

exit 0