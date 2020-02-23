echo -n "Alias: "
read ALIAS

if [ ! -n "$ALIAS" ]; then
    printf "Cannot be empty! Try again."
    exit 1
fi

printf "\nSet up scratch org ... \n"
sfdx force:org:create -s -a $ALIAS -f config/project-scratch-def.json

printf "\nPush source ... \n"
sfdx force:source:push -u $ALIAS

printf "\nAssign Permissions ... \n"
sfdx force:user:permset:assign -n Partner_ERP_Full_Access -u $ALIAS

printf "\nImporting data ...\n"
sfdx force:data:tree:import -p data/plans/standard-plan.json -u $ALIAS