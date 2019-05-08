#import logging

#import azure.functions as func

import sys

import json

import requests

AppID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AppPassword="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
TenantID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
SubscriptionID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
RGName="PM-test-rg-06"
VNet="workLoadsVNETmzmxe"
Subnet=["wlSubnet1mzmxe", "wlSubnet2mzmxe"]
SubnetaddressPrefix=["172.1.0.0/24", "172.1.1.0/24"]
RouteName="WorkloadRoutemzmxe"


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
    #-------------------------------------------------------------
    Token=json.loads(response.content)
    return Token["access_token"]
#-------------------------------------------------------------
#Get Resource Group Name exists
#-------------------------------------------------------------
def SubnetAssociation():
    AccessToken = AccessTokenID()
    print (AccessToken)
    headers = {
        'Authorization': 'Bearer {0}'.format(AccessToken),
        'Content-Type': 'application/json',
    }
    params = (
        ('api-version', '2018-11-01'),
    )
    data1 = {'properties':{'addressPrefix':SubnetaddressPrefix[0],'routeTable':{'id':'/subscriptions/'+SubscriptionID+'/resourceGroups/'+RGName+'/providers/Microsoft.Network/routeTables/'+RouteName}}}
    data2 = {'properties':{'addressPrefix':SubnetaddressPrefix[1],'routeTable':{'id':'/subscriptions/'+SubscriptionID+'/resourceGroups/'+RGName+'/providers/Microsoft.Network/routeTables/'+RouteName}}}
    response1 = requests.put('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/virtualNetworks/' + VNet + '/subnets/' + Subnet[0] + '?api-version=2018-11-01', headers=headers, data=json.dumps(data1))
    response2 = requests.put('https://management.azure.com/subscriptions/' + SubscriptionID +'/resourceGroups/' + RGName +'/providers/Microsoft.Network/virtualNetworks/' + VNet + '/subnets/' + Subnet[1] + '?api-version=2018-11-01', headers=headers, data=json.dumps(data2))
    print (response1.content)
    print (response2.content)
    return
SubnetAssociation()
