#call to add string rg param
param([string]$resourceGroup)

#Script to connect and add multiple vms
Connect-AzAccount

#Request to add credential object into variable for ease of use
$adminCredential = Get-Credential -Message "Enter a username and pw for VM admin"

#loop to create multiple vm
for ($i=1; $i -le 3; $i++)
{
    $vmName = "ConferenceDemo" + $i
    Write-Host "Creating VM: " + $vmName
    #Function to actually create each vm
    New-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Credential $adminCredential -Image Win2022AzureEdition
}

#Creates the VM
New-AzVm -ResourceGroupName $resourceGroup -Name $vmName -Credential $adminCredential -Image Win2022AzureEdition
