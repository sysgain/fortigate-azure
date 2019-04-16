#!/bin/bash

deletevm=$1
deletenic=$2
deletensg=$3
deletepip=$4
deletevnet=$5
deletedisk=$6
deleteroutetable=$7
deleteroute=$8
rgName=$9


#################################################

#Deleting the existing workload vm 

#################################################

az vm delete -g $rgName -n $deletevm --yes

az network nic delete -g $rgName -n $deletenic 

az network nsg delete -g $rgName -n $deletensg 

az network public-ip delete -g $rgName -n $deletepip 

az network vnet delete -g $rgName -n $deletevnet 

az disk delete --name $deletedisk --resource-group $rgName

az network route-table route delete -g $rgName --route-table-name $deleteroutetable -n $deleteroute 

az network route-table delete -g $rgName -n $deleteroutetable