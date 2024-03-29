﻿#Import the Azure PowerShell module.
Import-Module -Name Az

#Connect to an Azure Account.
Connect-AzAccount

#Define Azure variables for a vm
$vmName = "HelloWorldVM"
$resourceGroup = "Practice"

#Create Azure crendentials
$adminCredential = Get-Credential -Message "Enter a username and pw for AZAdmin"

#Create a vm in Azure
New-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Credential $adminCredential -Image Win2022AzureEdition
