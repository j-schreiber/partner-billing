#!/bin/bash
set -e

alias=
duration=7
configFile=config/default-scratch-def.json
requiredParamMissing="false"
installationKeys=
devhubusername="Production"

while getopts a:d:f:p:k: option
do
    case "${option}" in
        a )             alias=${OPTARG};;
        d )             duration=${OPTARG};;
        f )             configFile=${OPTARG};;
        p )             packageName=${OPTARG};;
        k )             installationKeys=${OPTARG};;
    esac
done

if [ -z "$alias" ]; then
    requiredParamMissing="true"
    echo "Missing required parameter: alias. Use '-a MyAlias'"
fi

if [ $requiredParamMissing == "true" ]
then
    exit 1
fi

echo "mkdir -p force-app"
mkdir -p force-app

echo "sfdx force:org:create -v $devhubusername -d $duration -f $configFile -a $alias -s"
sfdx force:org:create -v $devhubusername -d $duration -f $configFile -a $alias -s

echo "sfdx force:source:push -u $alias"
sfdx force:source:push -u $alias

echo "sfdx force:user:permset:assign -n PartnerBilling_Administrator -u $alias"
sfdx force:user:permset:assign -n PartnerBilling_Administrator -u $alias

echo "sfdx force:user:permset:assign -n PartnerBilling_Core_FullAccess -u $alias"
sfdx force:user:permset:assign -n PartnerBilling_Core_FullAccess -u $alias

echo "sfdx force:user:permset:assign -n PartnerBilling_Developer -u $alias"
sfdx force:user:permset:assign -n PartnerBilling_Developer -u $alias

echo "sfdx force:data:tree:import -p data/plans/standard-plan.json -u $alias"
sfdx force:data:tree:import -p data/plans/standard-plan.json -u $alias

echo "sfdx force:org:open -u $alias"
sfdx force:org:open -u $alias