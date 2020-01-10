#!/bin/bash
HOST="$1"
PORT="$2"
LOGFILE="$3"
HOSTNAME=$(hostname)

if [ $HOSTNAME == 'client' ]; then
        echo 'Client Machine found Test to see if Server is alive'
        while true; do
        ANS=$(nc -vn $HOST $PORT </dev/null; echo $?)
        if [ $ANS == 0 ]; then
             echo "Success Connecting to $HOST on $PORT"
             break
        fi
        done

        echo 'Run IPERF CLIENT'
        printf "\033c"
        echo "Begin Test"
        sudo iperf3 -u -c $HOST -J --logfile $LOGFILE
		cd /opt/tools/publish
		sudo ./ReadIperf $LOGFILE
fi
if [ $HOSTNAME == 'server' ]; then
        echo 'Server Machine Found'
        echo "Run IPERF Server"
        printf "\033c"
        iperf3 -s
fi

