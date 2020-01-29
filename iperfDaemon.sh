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
        IPERF_TOS=`cat /tmp/iperfTOS`

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
            IPERF_ARGS = ""
            if [ $IPERF_PROTOCOL == "UDP" ]; then
                IPERF_ARGS = "${IPERF_ARGS} -u "
            fi
            if [ $IPERF_TOS == "Minimize Delay" ]; then
                IPERF_ARGS = "${IPERF_ARGS} -tos 0x10 "
            fi            
            sudo iperf3 $IPERF_ARGS -c $HOST -p $PORT -t $IPERF_RUNTIME -J --logfile "${LOGFILE}${ITERATOR}.json" 
            curl -vX POST -H "Content-Type: application/json" -H "x-functions-key: s3VugHYN/fHRa6v2b/B58GwMF2taESnqXLFDQKaLAURJYPFxX4QYPA==" https://llfunc.azurewebsites.net/api/InjectionManager?resourceGroupName=LL_Fixed_AccNet_NoPPG_CUS -d "@${LOGFILE}${ITERATOR}.json"
            echo $i
            sleep $IPERF_COOLDOWN
            a=`expr $ITERATOR + 1`
        done
    fi
fi