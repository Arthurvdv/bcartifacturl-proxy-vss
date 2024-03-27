[CmdletBinding()]
param()

# For more information on the Azure DevOps Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation

try {
    # Get the input parameters
    $instanceUri = Get-VstsInput -Name instanceUri
    $type = Get-VstsInput -Name type
    $country = Get-VstsInput -Name country
    $version = Get-VstsInput -Name version
    $select = Get-VstsInput -Name select
    $storageAccount = Get-VstsInput -Name storageAccount
    $sasToken = Get-VstsInput -Name sasToken
    $accept_insiderEula = Get-VstsInput -Name accept_insiderEula

    Write-Host "*** Task Inputs:"
    Write-Host ""
    Write-Host -NoNewLine "name                           "; Write-Host "value"
    Write-Host -NoNewLine "----                           "; Write-Host "-----"
    Write-Host -NoNewLine "instanceUri                    "; Write-Host $instanceUri
    Write-Host -NoNewLine "type                           "; Write-Host $type
    Write-Host -NoNewLine "country                        "; Write-Host $country
    Write-Host -NoNewLine "version                        "; Write-Host $version
    Write-Host -NoNewLine "select                         "; Write-Host $select
    Write-Host -NoNewLine "storageAccount                 "; Write-Host $storageAccount
    Write-Host -NoNewLine "sasToken                       "; Write-Host $sasToken
    Write-Host -NoNewLine "accept_insiderEula             "; Write-Host $accept_insiderEula
    Write-Host ""
    Write-Host ""

    if ($accept_insiderEula.ToLower() -eq "true" `
            -and $select.ToLower() -ne "nextminor" `
            -and $select.ToLower() -ne "nextmajor" `
            -and [String]::IsNullOrEmpty($storageAccount)) {
        Write-Host "##[group]Adjusting input accept_insiderEula from '$($accept_insiderEula)' to 'false'"
        Write-Host "Accessing insider builds require accepting the insider EULA (https://go.microsoft.com/fwlink/?linkid=2245051)."
        Write-Host "The selected '$($select)' build does not belong to the category of insider builds."
        Write-Host "Adjusting the accept_insiderEula value from '$($accept_insiderEula)' to 'false' to enhance the likelihood of retrieving a cached result."
        $accept_insiderEula = 'false'
        Write-Host "The accept_insiderEula property has been updated to '$($accept_insiderEula)'."
        Write-Host "##[endgroup]"
    }

    if ($version -and ($select.ToLower() -eq "daily" -or $select.ToLower() -eq "weekly")) {
        Write-Host "##[group]Adjusting input select from '$($select)' to 'Latest'."
        Write-Host "When specifying a version, het is not possible to select Daily or Weekly builds.".
        Write-Host "Adjusting the select value from '$($select)' to 'Latest'."
        $select = 'Latest'
        Write-Host "The select property has been updated to '$($select)'."
        Write-Host "##[endgroup]"
    }

    $param = $null
    if ($instanceUri) { $param += " -instanceUri $($instanceUri.ToLower()) " }
    if ($type) { $param += " -type $($type.ToLower())" }
    if ($country) { $param += " -country $($country.ToLower())" }
    if ($version) { $param += " -version $version" }
    if ($select) { $param += " -select $($select.ToLower())" }
    if ($storageAccount) { $param += " -storageAccount $storageAccount" }
    if ($sasToken) { $param += " -sasToken $sasToken" }
    if ($accept_insiderEula.ToLower() -eq "true") { $param += " -accept_insiderEula" }

    Import-Module .\Get-BCArtifactUrlThroughProxy.ps1 | Out-Null
    $command = "Get-BCArtifactUrlThroughProxy" + $param
    $bcartifacturl = Invoke-Expression $command

    if ([string]::IsNullOrEmpty($bcartifacturl)) {
        Write-Host "##[warning]Switching to BcContainerHelper"
        Import-Module .\Import-PowerShellModule.ps1 | Out-Null
        Import-PowerShellModule -moduleName 'BcContainerHelper' 

        $command = "Get-BCArtifactUrl" + $param
        $bcartifacturl = Invoke-Expression $command
    }

    if ([String]::IsNullOrEmpty($bcartifacturl)) {
        Write-Host "##[error]An unexpected error has occurred: The retrieval of artifact URLs has failed."
        Write-Host "##vso[task.complete result=Failed;]"
        exit
    }

    Write-Host "*** Set Pipeline variable `$(BCARTIFACTURL_PROXY) = '$bcartifacturl'"
    Write-Host "##vso[task.setvariable variable=BCARTIFACTURL_PROXY;]$bcartifacturl"
    Write-Host "##vso[task.complete result=Succeeded;]"
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
