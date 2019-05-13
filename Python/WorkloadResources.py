#import logging

#import azure.functions as func

import sys

import json

import requests

import time

AppID="XXXXXXXXXXXX"
AppPassword="XXXXXXXXXX"
TenantID="XXXXXXXXXXXXXXXXXXXXX"
SubscriptionID="XXXXXXXXXXXXXXXXXXXXXX"
RGName="FG-Test-RG-1006"
VmName1="workloadVM-16imww"
VmName2="workloadVM-26imww"
Nic1="wl-nic-16imww"
Nic2="wl-nic-26imww"
Disk1="workloadVM-16imww_disk1_7cea26bc16f545e6ae2a91f911fa751a"
Disk2="workloadVM-26imww_disk1_5e3215a6e3f44c41bf810e86c676fb31"
NSG="workload-nsg6imww"
RouteTable="WorkloadRoute6imww"
Route="to-InternetDefaultRoute"
VNet="workLoadsVNET6imww"
#------------------------------------------------------------
#Get Azure Token ID
#------------------------------------------------------------
def AccessTokenID():
    data = {
        'grant_type': 'client_credentials',
        'client_id': AppID,
        'client_secret': AppPassword,
        'resource': 'https://management.azure.com/'
    }

    response = requests.post('https://login.microsoftonline.com/' + TenantID + '/oauth2/token', data=data)

    Token=json.loads(response.content)
    return Token["access_token"]

#-------------------------------------------------------------
#Get Virtual Machine Name, IF exists
#-------------------------------------------------------------

def WorkLoadVMDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-06-01'),
    )
    for i in VmName1,VmName2:
        response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Compute/virtualMachines/'+ i, params=params,headers=headers)
        response2 = requests.get('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Compute/virtualMachines/'+ i +'/instanceView', params=params,headers=headers)
        while response2.status_code == 200:
            print ('Deleteing VM: '+ i)
            print ('VM Deleting....')
            time.sleep(10)
            response3 = requests.get('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Compute/virtualMachines/'+ i +'/instanceView', params=params,headers=headers)
            response2.status_code = response3.status_code
        else:
            print ('VM Deleted')
    return

def WorkLoadNICDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    for i in Nic1,Nic2:
        response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/networkInterfaces/' + i, params=params,headers=headers)
        response2 = requests.get('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/networkInterfaces/' + i, params=params,headers=headers)
        if response1.status_code == 202:
            print ('Deleting NIC: '+ i)
            response2 = requests.get('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/networkInterfaces/' + i, params=params,headers=headers)
            while response2.status_code == 200:
                print ('Deleting....'+ i)
                time.sleep(10)
                response3 = requests.get('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/networkInterfaces/' + i, params=params,headers=headers)
                response2.status_code = response3.status_code
            else:
                print ('NIC '+ i +' Deleted')
        else:
            print ('NIC '+ i +' Deleted or does not exists or exception')
    return

def WorkLoadDiskDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-06-01'),
    )

    for i in Disk1,Disk2:
        response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Compute/disks/' + i, params=params,headers=headers)
        while response1.status_code == 202:
            print ('Deleting Disk: '+ i)
            time.sleep(10)
            response2 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Compute/disks/' + i, params=params,headers=headers)
            response1.status_code = response2.status_code
        else:
            print ('Disk '+ i +' Deleted or does not exists or exception')
    return

def WorkLoadNSGDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/networkSecurityGroups/' + NSG, params=params,headers=headers)
    while response1.status_code == 202:
            print ('Deleting NSG '+ NSG)
            time.sleep(10)
            response2 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/networkSecurityGroups/' + NSG, params=params,headers=headers)
            response1.status_code = response2.status_code
    else:
            print ('NSG '+ NSG +' Deleted or does not exists or exception')
    return

def WorkLoadRouteDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/routeTables/' + RouteTable +'/routes/' + Route, params=params,headers=headers)
    while response1.status_code == 202:
            print ('Deleting Rotue '+ Route)
            time.sleep(10)
            response2 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/routeTables/' + RouteTable +'/routes/' + Route, params=params,headers=headers)
            response1.status_code = response2.status_code
    else:
            print ('Route '+ Route +' Deleted or does not exists or exception')
    return

def WorkLoadRouteTableDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/routeTables/' + RouteTable, params=params,headers=headers)
    while response1.status_code == 202:
            print ('Deleting RotueTable '+ RouteTable)
            time.sleep(10)
            response2 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/routeTables/' + RouteTable, params=params,headers=headers)
            response1.status_code = response2.status_code
    else:
            print ('Route '+ RouteTable +' Deleted or does not exists or exception')
    return

def WorkLoadVNetDelete():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    response1 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/virtualNetworks/' + VNet, params=params,headers=headers)
    print (response1.status_code)
    while response1.status_code == 202:
            print ('Deleting VNet '+ VNet)
            time.sleep(10)
            response2 = requests.delete('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/virtualNetworks/' + VNet, params=params,headers=headers)
            response1.status_code = response2.status_code
    else:
            print ('VNet '+ VNet +' Deleted or does not exists or exception')
    return
WorkLoadVMDelete()
WorkLoadNICDelete()
WorkLoadDiskDelete()
WorkLoadNSGDelete()
WorkLoadRouteDelete()
WorkLoadRouteTableDelete()
WorkLoadVNetDelete()
