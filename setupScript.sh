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
    sudo yum install $DEB_PACKAGE_NAME_NC -y
fi

sudo firewall-offline-cmd -p 5201:tcp
sudo kill -HUP firewalld
sudo mkdir /opt/tools
cd /opt/tools
sudo wget https://stageb15002ab66154dae8e2.blob.core.windows.net/lowlatency/ingestapp/publish.zip
sudo unzip -d /opt/tools publish.zip
sudo chmod 755 /opt/tools/publish/ReadIperf
sudo git clone https://github.com/quique-z/LowLatency.git
sudo chmod +x /opt/tools/LowLatency/perfScript.sh
sudo chmod +x /opt/tools/LowLatency/iperfDaemon.sh
sudo crontab -l ; echo '* * * * * /opt/tools/LowLatency/iperfDaemon.sh > /tmp/env.output' | crontab -