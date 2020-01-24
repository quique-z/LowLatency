HOST="10.0.0.4"
PORT="5201"
LOGFILE="/opt/tools/output"
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
    echo 'Client Machine found'
    HAS_EXECUTED=$(ls /tmp/iperfTestDone | wc -l)
    if [ $HAS_EXECUTED == '0' ]    
    then
        echo "Done" > /tmp/iperfTestDone
        IPERF_RUNTIME=`cat /tmp/iperfRunTime`
        IPERF_COOLDOWN=`cat /tmp/iperfCoolTime`
        IPERF_REPS=`cat /tmp/iperfReps`
        IPERF_PROTOCOL=`cat /tmp/iperfProtocol`

        while true; do
        ANS=$(nc -vn $HOST $PORT </dev/null; echo $?)
        if [ $ANS == 0 ]; then
             echo "Success Connecting to $HOST on $PORT"
             break
        fi
        done

        ITERATOR=0
        while [ $ITERATOR -lt $IPERF_REPS ]
        do
            echo "Run IPERF CLIENT"
            printf "\033c"
            echo "Begin Test"
            echo "Output file: ${LOGFILE}${ITERATOR}.json"
            if [ $IPERF_PROTOCOL == "UDP" ]; then
                sudo iperf3 -u -c $HOST -p $PORT -t $IPERF_RUNTIME -J --logfile "${LOGFILE}${ITERATOR}.json" 
            else
                sudo iperf3 -c $HOST -p $PORT -t $IPERF_RUNTIME -J --logfile "${LOGFILE}${ITERATOR}.json" 
            fi
            cd /opt/tools/publish
            sudo ./ReadIperf "${LOGFILE}${ITERATOR}.json" 
            echo $i
            sleep $IPERF_COOLDOWN
            a=`expr $ITERATOR + 1`
        done
    fi
fi