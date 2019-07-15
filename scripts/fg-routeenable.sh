#! /bin/bash
demoVnetAssociateRouteUrl=$1
sleep 120
curl "$demoVnetAssociateRouteUrl"
sleep 60
curl "$demoVnetAssociateRouteUrl"
