function Get-BCArtifactUrlThroughProxy {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [String] $instanceUri = 'https://bca-url-proxy.azurewebsites.net/bca-url',
        [ValidateSet('OnPrem', 'Sandbox')]
        [String] $type = '',
        [String] $country = '',
        [String] $version = '',
        [ValidateSet('Latest', 'First', 'All', 'Closest', 'SecondToLastMajor', 'Current', 'NextMinor', 'NextMajor', 'Daily', 'Weekly')]
        [String] $select = 'Latest',
        # [DateTime] $after,
        # [DateTime] $before,
        [String] $storageAccount = '',
        [String] $sasToken = '',
        [switch] $accept_insiderEula,
        # [switch] $doNotCheckPlatform
        [String] $cacheExpiration
    )

    if ($type -or $country -or $version) {
        if ([String]::IsNullOrEmpty($type)) { $type = 'Sandbox' }
        if ([String]::IsNullOrEmpty($country)) { $country = 'W1' }
    }

    $bcartifacturlproxy = $instanceUri
    $bcartifacturlproxy += "/$type"
    $bcartifacturlproxy += "/$country"
    if ($version) { $bcartifacturlproxy += "/$version" }

    $bcartifacturlproxy += '?DoNotRedirect=true'
    if ($select) { $bcartifacturlproxy += "&select=$select" }
    if ($storageAccount) { $bcartifacturlproxy += "&storageAccount=$storageAccount" }
    if ($accept_insiderEula) { $bcartifacturlproxy += "&accept_insiderEula" }
    if ($cacheExpiration) { $bcartifacturlproxy += "&cacheExpiration=$cacheExpiration" }

    try {
        Write-Host "##[command]Invoke-WebRequest $($bcartifacturlproxy) -UseBasicParsing"
        $artifactUrl = Invoke-WebRequest $bcartifacturlproxy -UseBasicParsing

        Write-Host "##[group]Response $($artifactUrl.StatusDescription)"
        Write-Host -NoNewLine "HTTP:      " ; Write-Host $($artifactUrl.StatusCode)
        Write-Host -NoNewLine "Cached:    " ; Write-Host $($artifactUrl.Headers.'X-bcaup-from-cache')
        Write-Host -NoNewLine "Timestamp: " ; Write-Host $($artifactUrl.Headers.'X-bcaup-cache-timestamp')
        Write-Host -NoNewLine "Command:   " ; Write-Host $($artifactUrl.Headers.'X-bccontainerhelper-command')
        Write-Host "##[endgroup]"

        return $artifactUrl.Content.Trim()
    }
    catch { 
        Write-Host "##[warning]An exception was caught: $($_.Exception.Message)"
    } 
}