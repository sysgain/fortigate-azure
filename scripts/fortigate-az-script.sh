#!/bin/bash
rgName=$1
peerfrom=$2
peerto=$3
vnetfrom=$4
vnetto=$5
appid=$6
routetableName=$7
routeName=$8
nexthopIP=$9
subnetName=${10}

#############################################################

#Peering the local network with the exisiting virtual network

#############################################################


az network vnet peering create -g $rgName -n $peerfrom --vnet-name $vnetfrom --remote-vnet $vnetto --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit

az network vnet peering create -g $rgName -n $peerto --vnet-name $vnetto --remote-vnet $vnetfrom --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit

az role assignment create --role "Network Contributor" --assignee $appid  --resource-group $rgName

az role assignment create --role "Owner" --assignee $appid --resource-group $rgName


az network route-table create -g $rgName -n $routetableName

az network route-table route create -g $rgName --route-table-name $routetableName -n $routeName --next-hop-type VirtualAppliance --address-prefix 0.0.0.0/0 --next-hop-ip-address $nexthopIP


az network vnet subnet update -g $rgName -n ${subnetName} --vnet-name $vnetto --route-table $routetableName