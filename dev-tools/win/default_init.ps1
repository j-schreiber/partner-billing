# PARAMS
Param(
    [Alias("a")]
    [parameter(
        Mandatory=$true,
        HelpMessage="Scratch Org Alias that will be used for this Org"
    )][string]$ScratchOrgAlias,
    [Alias("d")]
    [int]$Duration = 7
)

Write-Host "sfdx force:org:create -s -a $ScratchOrgAlias -d $Duration -f config/project-scratch-def.json"
sfdx force:org:create -s -a $ScratchOrgAlias -d $Duration -f .\config\project-scratch-def.json

Write-Host "sfdx force:source:push -u $ScratchOrgAlias"
sfdx force:source:push -u $ScratchOrgAlias

Write-Host "sfdx force:user:permset:assign -n PartnerBilling_Invoicing_FullAccess -u $ScratchOrgAlias"
sfdx force:user:permset:assign -n PartnerBilling_Invoicing_FullAccess -u $ScratchOrgAlias

Write-Host "sfdx force:user:permset:assign -n PartnerBilling_Core_FullAccess -u $ScratchOrgAlias"
sfdx force:user:permset:assign -n PartnerBilling_Core_FullAccess -u $ScratchOrgAlias

Write-Host "sfdx force:user:permset:assign -n PartnerBilling_Developer -u $ScratchOrgAlias"
sfdx force:user:permset:assign -n PartnerBilling_Developer -u $ScratchOrgAlias

Write-Host "sfdx force:user:permset:assign -n PartnerBilling_Administrator -u $ScratchOrgAlias"
sfdx force:user:permset:assign -n PartnerBilling_Administrator -u $ScratchOrgAlias

Write-Host "sfdx force:data:tree:import -p .\data\plans\standard-plan.json -u $ScratchOrgAlias"
sfdx force:data:tree:import -p .\data\plans\standard-plan.json -u $ScratchOrgAlias

Write-Host "sfdx force:org:open -u $ScratchOrgAlias"
sfdx force:org:open -u $ScratchOrgAlias