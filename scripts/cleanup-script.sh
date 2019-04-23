#!/bin/bash

deletevm1=$1
deletevm2=$2
deletenic1=$3
deletenic2=$4
deletensg=$5
deletedisk1=$6
deletedisk2=$7
deletevnet=$8
deleteroutetable=$9
deleteroute=${10}
rgName=${11}


#################################################

#Deleting the existing workload vm 

#################################################

az vm delete -g ${rgName} -n $deletevm1 --yes

az vm delete -g ${rgName} -n $deletevm2 --yes

az network nic delete -g ${rgName} -n $deletenic1

az network nic delete -g ${rgName} -n $deletenic2 

az network nsg delete -g ${rgName} -n $deletensg 

az network vnet delete -g ${rgName} -n $deletevnet 

az disk delete --name $deletedisk1 --resource-group ${rgName}

az disk delete --name $deletedisk2 --resource-group ${rgName}

az network route-table route delete -g ${rgName} --route-table-name ${deleteroutetable} -n ${deleteroute}

az network route-table delete -g ${rgName} -n ${deleteroutetable}
