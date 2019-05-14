#! /bin/bash
azureuser=$1
AppID=$2
AppPassword=$3
TenantID=$4
SubscriptionID=$5
RGName=$6
VNet=$7
subnetname=$8
subnetaddprefix=$9
RouteTable=${10}

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

wget "https://storageccqia.blob.core.windows.net/cc-iot/fortigate/FortiGate-Latest/scripts/enableRouteExisting.py"

touch cleanup1.log

python3 enableRouteExisting.py ${AppID} ${AppPassword} ${TenantID} ${SubscriptionID} ${RGName} ${VNet} ${subnetname} ${subnetaddprefix} ${RouteTable} >> cleanup1.log 2>&1
