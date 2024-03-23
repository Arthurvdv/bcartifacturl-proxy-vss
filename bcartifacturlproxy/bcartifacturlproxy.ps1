[CmdletBinding()]
param()

# For more information on the Azure DevOps Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation

try {
    # Get the input parameters
    $baseUri = Get-VstsInput -Name baseUri
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
    Write-Host -NoNewLine "-----                          "; Write-Host "-----"
    Write-Host -NoNewLine "baseUri                        "; Write-Host $baseUri
    Write-Host -NoNewLine "type                           "; Write-Host $type
    Write-Host -NoNewLine "country                        "; Write-Host $country
    Write-Host -NoNewLine "version                        "; Write-Host $version
    Write-Host -NoNewLine "select                         "; Write-Host $select
    Write-Host -NoNewLine "storageAccount                 "; Write-Host $storageAccount
    Write-Host -NoNewLine "sasToken                       "; Write-Host $sasToken
    Write-Host -NoNewLine "accept_insiderEula             "; Write-Host $accept_insiderEula
    Write-Host ""
    Write-Host ""
    
    $param = $null
    if ($baseUri) { $param += " -baseUri $($baseUri.ToLower()) " }
    if ($type) { $param += " -type $($type.ToLower())" }
    if ($country) { $param += " -country $($country.ToLower())" }
    if ($version) { $param += " -version $version" }
    if ($select) { $param += " -select $($select.ToLower())" }
    if ($storageAccount) { $param += " -storageAccount $storageAccount" }
    if ($sasToken) { $param += " -sasToken $sasToken" }
    if ($accept_insiderEula.ToLower() -eq "true") { $param += " -accept_insiderEula" }

    Write-Host "*** Execute bcartifacturl-proxy"
    Import-Module .\Get-BCArtifactUrlThroughProxy.ps1 | Out-Null
    $command = "Get-BCArtifactUrlThroughProxy" + $param
    $bcartifacturl = Invoke-Expression $command

    if ([string]::IsNullOrEmpty($bcartifacturl)) {
        Write-Host "##[warning]Switching to BcContainerHelper"
        Import-Module .\Import-PowerShellModule.ps1 | Out-Null
        Import-PowerShellModule -moduleName 'BcContainerHelper' 

        Write-Host "*** Execute Get-BCArtifactUrl"
        $command = "Get-BCArtifactUrl" + $param
        $bcartifacturl = Invoke-Expression $command
    }

    Write-Host "*** Set Pipeline variable `$(BCARTIFACTURL_PROXY) = '$bcartifacturl'"
    Write-Host "##vso[task.setvariable variable=BCARTIFACTURL_PROXY;]$bcartifacturl"
}
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
