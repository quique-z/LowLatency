SETUP="$1"
if [ $SETUP == 's' ]; then
    YUM_PACKAGE_NAME_GIT="git"
    DEB_PACKAGE_NAME_GIT="git"
    YUM_PACKAGE_NAME_IPERF="iperf3"
    DEB_PACKAGE_NAME_IPERF="iperf3"
    YUM_PACKAGE_NAME_NC="nc"
    DEB_PACKAGE_NAME_NC="nc"
    YUM_CMD=$(which yum)
    APT_GET_CMD=$(which apt-get)
    if [[ ! -z $YUM_CMD ]]; then
        sudo yum install $YUM_PACKAGE_NAME_GIT -y
        sudo yum install $YUM_PACKAGE_NAME_IPERF -y
        sudo yum install $YUM_PACKAGE_NAME_NC -y
    elif [[ ! -z $APT_GET_CMD ]]; then
        sudo apt-get install $DEB_PACKAGE_NAME_GIT -y
        sud apt-get install $DEB_PACKAGE_NAME_IPERF -y
        sudo apt-get install $DEB_PACKAGE_NAME_NC -y
    fi

    sudo firewall-offline-cmd -p 5201:tcp
    sudo firewall-offline-cmd -p 5201:udp
    sudo kill -HUP firewalld
    sudo chmod +x /opt/tools/LowLatency/iperfDaemon.sh
    sudo crontab -u msadmin -l ; echo '* * * * * /opt/tools/perfScript.sh' | crontab -
else
    HOST="10.0.0.4"
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
                    IPERF_ARGS = "${IPERF_ARGS} -S 0x10 "
                fi           
                python3 ./testscript.py -c $HOST --time $IPERF_RUNTIME $IPERF_ARGS -O 5 --test-parallel 1,50,128
                echo $i
                sleep $IPERF_COOLDOWN
                a=`expr $ITERATOR + 1`
            done
        fi
    fi    
fi