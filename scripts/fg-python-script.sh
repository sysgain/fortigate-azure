#! /bin/bash
azureuser=$1
cd /home/$azureuser
echo "AppID=$2" >>outparams.txt
echo "AppPassword=$3" >>outparams.txt
echo "TenantID=$4" >>outparams.txt
echo "SubscriptionID=$5" >>outparams.txt
echo "RGName=$6" >>outparams.txt
echo "VmName1=$7" >>outparams.txt
echo "VmName2=$8" >>outparams.txt
echo "Nic1=$9" >>outparams.txt
echo "Nic2=${10}" >>outparams.txt
echo "Disk1=${11}" >>outparams.txt
echo "Disk2=${12}" >>outparams.txt
echo "NSG=${13}" >>outparams.txt
echo "RouteTable=${14}" >>outparams.txt
echo "Route=${15}" >>outparams.txt
echo "VNet=${16}" >>outparams.txt
AppID=$2
AppPassword=$3
TenantID=$4
SubscriptionID=$5
RGName=$6
Route=${15}
VNet=${16}
subnetname1=${17}
subnetname2=${18}
subnetaddprefix1=${19}
subnetaddprefix2=${20}

#download all the pr-requsites to install python packages and all the python files to the home dir

sudo apt-get -y update
sudo apt-get -y upgrade
sudo add-apt-repository ppa:jonathonf/python-3.6 -y 
sudo apt-get update -y
sudo apt-get install python3.6 -y
sleep 30
sudo apt-get install -y python3-pip
sleep 60
sudo pip3 install requests 
sudo apt-get install build-essential libssl-dev libffi-dev python-dev -y
sudo apt-get install -y python3-venv
sudo python3 -m venv my_env
source my_env/bin/activate
sleep 60

cd /home/$azureuser

wget "https://storageccqia.blob.core.windows.net/cc-iot/fortigate/FortiGate-Latest/scripts/cleanup.sh"
wget "https://storageccqia.blob.core.windows.net/cc-iot/fortigate/FortiGate-Latest/scripts/cleanupSpokeVnet.py"
wget "https://storageccqia.blob.core.windows.net/cc-iot/fortigate/FortiGate-Latest/scripts/enableRoute.py"

touch cleanup1.log

python3 enableRoute.py ${AppID} ${AppPassword} ${TenantID} ${SubscriptionID} ${RGName} ${VNet} ${subnetname1} ${subnetname2} ${subnetaddprefix1} ${subnetaddprefix2} ${Route} >> cleanup.log1 2>&1
