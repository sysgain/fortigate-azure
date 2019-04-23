#! /bin/bash
deletevm=$1
deletenic=$2
deletensg=$3
deletevnet=$4
deletedisk=$5
deleteroutetable=$6
deleteroute=$7
rgName=$8
#################################################

#Deleting the existing workload vm 

#################################################

az vm delete -g $rgName -n $deletevm --yes
az network nic delete -g $rgName -n $deletenic 
az network nsg delete -g $rgName -n $deletensg 
az network vnet delete -g $rgName -n $deletevnet 
az disk delete --name $deletedisk --resource-group $rgName
az network route-table route delete -g $rgName --route-table-name $deleteroutetable -n $deleteroute 
az network route-table delete -g $rgName -n $deleteroutetable
