if [[ $HOSTNAME == server* ]]; then
        while 1
        do
            if [(ps -aux | grep "iperf3" | wc -l) -eq 1] 
            then
                echo 'Server Machine Found.\nIperf server is off.\nTurning on...'
                printf "\033c"
                iperf3 -s
            fi
            sleep 60
        done
fi