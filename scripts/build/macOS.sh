#!/bin/bash
set -e

installationKey=
username="StagingSandbox"
devhubusername="Production"
packageId="0Ho4P000000GmhySAC"
buildPackage="true"
releaseCandidate="false"

while getopts k:u:v:ir option
do
    case "${option}" in
        k )             installationKey=${OPTARG};;
        u )             username=${OPTARG};;
        v )             devhubusername=${OPTARG};;
        i )             buildPackage="false";;
        r )             releaseCandidate="true";;
    esac
done

if [ "$buildPackage" == "true" ]; then
    if [ "$releaseCandidate" == "true" ]; then
        echo "sfdx force:package:version:create -p $packageId -v $devhubusername -w 60 -k $installationKey -c --json"
        sfdx force:package:version:create -p $packageId -v $devhubusername -w 60 -k $installationKey -c
    else
        echo "sfdx force:package:version:create -p $packageId -v $devhubusername -w 60 -k $installationKey --skipvalidation --json"
        sfdx force:package:version:create -p $packageId -v $devhubusername -w 60 -k $installationKey --skipvalidation --json
    fi
fi

echo "python ../../scripts/build/install-latest-version.py -k $installationKey -u $username -p $packageId"
python ../../scripts/build/install-latest-version.py -k $installationKey -u $username -p $packageId

echo "sfdx force:apex:test:run -w 10 -c -r human -u $username"
sfdx force:apex:test:run -w 10 -c -r human -u $username