#! /bin/bash
azureuser=$1

cd /home/$azureuser

echo "vmname1=$2" >>outparams.txt
echo "vmname2=$3" >>outparams.txt
echo "nicname1=$4" >>outparams.txt
echo "nicname2=$5" >>outparams.txt
echo "nsgname=$6" >>outparams.txt
echo "diskname1=$7" >>outparams.txt
echo "diskname2=$8" >>outparams.txt
echo "vnetname=$9" >>outparams.txt
echo "routename=${10}" >>outparams.txt
echo "routetablename=${11}" >>outparams.txt
echo "rgname=${12}" >>outparams.txt

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
