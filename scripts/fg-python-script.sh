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


#download the python files to the home dir

sudo apt-get -y update

sudo apt-get -y upgrade

sudo add-apt-repository ppa:jonathonf/python-3.6 -y 

sudo apt-get update -y

sudo apt-get install python3.6 -y

sudo apt-get install -y python3-pip

pip3 install requests 

sudo apt-get install build-essential libssl-dev libffi-dev python-dev -y

sudo apt-get install -y python3-venv

python3 -m venv my_env

source my_env/bin/activate

cd /home/$azureuser

#wget "cleanupscript"
#wget "python script"
