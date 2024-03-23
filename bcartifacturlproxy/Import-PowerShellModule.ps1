function Import-PowerShellModule {
    [CmdletBinding()]
    param (
        [String] $moduleName
    )

    Write-Host "*** Check for PowerShell module $moduleName"

    # If module is available then say that and do nothing
    if (Get-Module -ListAvailable | Where-Object { $_.Name -eq $moduleName }) {
        Write-Host "##[command]Import-Module $moduleName -DisableNameChecking"
        Import-Module $moduleName -DisableNameChecking
    }
    else {
        # If module is not available on disk, but is in online gallery then install
        if (Find-Module -Name $moduleName | Where-Object { $_.Name -eq $moduleName }) {
            Write-Host "##[command]Install-Module -Name $moduleName -Force -Scope CurrentUser -AllowClobber"
            Install-Module -Name $moduleName -Force -Scope CurrentUser -AllowClobber
        }
        else {
            # If the module is not imported, not available and not in the online gallery then abort
            Write-Host "*** Module $moduleName not imported, not available and not in an online gallery."
            exit 1
        }
    }
}