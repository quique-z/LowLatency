if [[ $HOSTNAME == server* ]]; then
    IPERF_COUNT=$(ps -aux | grep "iperf3" | wc -l)
    if [ $IPERF_COUNT == '1' ]
    then
        echo 'Server Machine Found.\nIperf server is off.\nTurning on...'
        /bin/printf "\033c"
        /bin/iperf3 -s -D
    fi
fi