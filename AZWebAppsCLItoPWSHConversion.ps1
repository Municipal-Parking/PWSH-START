#104 Training using AZCLI but converted to powershell

#Random number generator
$Random = Get-Random

#resource group name
$RGName = "Practice"

#which region chosen for the group, westUS region doesn't have a quota at all
$AZRegion = "East US"

#name of application service plan
$AZAPPPLAN = "popupappplan-$Random"

#name of web app
$AZWEBAPP = "popupwebapp-$Random"

#github url
$gitrepo = "https://github.com/Azure-Samples/php-docs-hello-world"

# Configure GitHub deployment from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
    isManualIntegration = "true";
}

#Don't forget to always connect. The labs are automatically connected.
Connect-AzAccount

#We ended up defining the string location EAST US because it wasn't working
#West US doesn't have a quota for appserviceplan or webapp
#Also, for Powershell, spacing on strings is important. eastus vs. East US
New-AzAppServicePlan -ResourceGroupName $RGName -Location "East US" -Name $AZAPPPLAN -tier basic
New-AzWebApp -name $AZWEBAPP -ResourceGroupName $RGName -Location "East US"  -AppServicePlan $AZAPPPLAN

#PWSH equivalent to az webapp deployment source config
#deploys webapp since repo url from github, specifically hello world
Set-AzResource -Properties $PropertiesObject -ResourceGroupName $RGName -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $AZWEBAPP/web -ApiVersion 2015-08-01 -Force
