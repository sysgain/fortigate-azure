#! /bin/bash
demoVnetAssociateRouteUrl=$1
sleep 60
curl "$demoVnetAssociateRouteUrl"
sleep 60
curl "$demoVnetAssociateRouteUrl"
