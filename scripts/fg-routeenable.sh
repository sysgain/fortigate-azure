#! /bin/bash
demoVnetAssociateRouteUrl=$1
curl "$demoVnetAssociateRouteUrl"
sleep 100
curl "$demoVnetAssociateRouteUrl"
