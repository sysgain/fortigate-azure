#! /bin/bash
serviceprincipal=$1
secretkey=$2
tenatid=$3
subscriptionid=$4
rgName=$5
wlsubnet=$6
wlvnet=$7
wlroutetableName=$8
azurelogin=$9
azurepassword=${10}

echo "=====================================installing the test website in workload VM========================================"

cd /home/$USER

git clone https://github.com/brannondorsey/SlowLoris
cd SlowLoris
sudo apt install docker.io -y
sudo docker pull httpd
sleep 40
sudo docker run -d --name apache -p 8888:80 -v "$PWD/www":/usr/local/apache2/htdocs/ httpd:2.4

#Install azure CLI
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get update
sleep 30s
sudo apt-get install apt-transport-https -y
sudo apt-get update && sudo apt-get install azure-cli -y
sleep 1m

cd /home/$USER

sudo az login -u "$azurelogin" -p "${azurepassword}" --tenant "$tenatid"

sudo az account set -s "$subscriptionid" 

echo "=====================================assigning the IAM roles to the current resource group================================="

az role assignment create --role "Network Contributor" --assignee "$serviceprincipal"  --resource-group "$rgName"

az role assignment create --role "Virtual Machine Contributor" --assignee "$serviceprincipal" --resource-group "$rgName"

echo "===============================associating the workload subnet to the workload route table================================"

az network vnet subnet update -g "$rgName" -n "$wlsubnet" --vnet-name "$wlvnet" --route-table "$wlroutetableName"
