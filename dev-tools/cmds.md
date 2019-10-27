# MANAGED PACKAGES
sfdx force:package:version:create -x -p "Partner Billing" -w 10 -v $DevHubAlias

sfdx force:package:install -s AllUsers -t Mixed -w 10 -b 5 -p "Partner Billing@0.1.1-1" -u $MyUatAlias

sfdx force:package:version:promote -p "Partner Billing@0.1.1-1"