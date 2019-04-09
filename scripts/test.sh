#!/bin/bash
rgName=$1
peerName1=$2
peerName2=$3
vnetName1=$4
vnetName2=$5
appid=$6
routetableName=$7
routeName=$8
nexthopIP=$9
subnetName=${10}
vnetName=${11}

az network vnet peering create -g $rgName -n $peerName1 --vnet-name $vnetName1 --remote-vnet $vnetName2 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit

az network vnet peering create -g $rgName -n $peerName2 --vnet-name $vnetName2 --remote-vnet $vnetName1 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit

az role assignment create --role "Network Contributor" --assignee $appid  --resource-group $rgName

az role assignment create --role "Owner" --assignee $appid --resource-group $rgName


az network route-table create -g $rgName -n $routetableName

az network route-table route create -g $rgName --route-table-name $routetableName -n $routeName --next-hop-type VirtualAppliance --address-prefix 0.0.0.0/0 --next-hop-ip-address $nexthopIP


az network vnet subnet update -g $rgName -n ${subnetName} --vnet-name ${vnetName} --route-table $routetableName
