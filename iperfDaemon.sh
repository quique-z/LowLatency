if [[ $HOSTNAME == server* ]]; then
    IPERF_COUNT=$(ps -aux | grep "iperf3" | wc -l)
    if [ $IPERF_COUNT == '1' ]
    then
        echo 'Server Machine Found.\nIperf server is off.\nTurning on...'
        /bin/printf "\033c"
        /bin/iperf3 -s -D
    fi
fi
if [[ $HOSTNAME == client* ]]; then
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