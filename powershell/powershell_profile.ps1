Import-Module PsGet
Import-Module Find-String
Import-Module VirtualEnvWrapper

Function Prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    $currPath = Split-Path (Get-Location) -Leaf
    Write-Host ($curr_user) -nonewline -foregroundcolor Green
    Write-Host "@" -nonewline
    Write-Host ($curr_host) -nonewline -foregroundcolor Yellow
    Write-Host ":" -nonewline
    Write-Host ($currPath) -nonewline -foregroundcolor DarkYellow

    $global:LASTEXITCODE = $realLASTEXITCODE
    Return '> '
}

Function Test-ElevationStatus {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $user = New-Object System.Security.Principal.WindowsPrincipal($id)
    $admin_role = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    $user.IsInRole($admin_role)
}

# Get a red screen if we're admin
If (Test-ElevationStatus) {
    (Get-Host).UI.RawUI.Backgroundcolor = 'DarkRed'
    Clear-Host
}

Function Start-PowerCLI {
    Add-PSSnapIn 'VMWare.VimAutomation.Core'
    Connect-VIServer -Server beaengvc1.beaeng.mfeeng.org
}
New-Alias -Name 'spc' -Value 'Start-PowerCLI' -Description 'Add snap-in and connect to VSphere'

# VirtualEnvWrapper
# -----------------
$ProjectHome = 'C:\source\dogrover'
New-Alias -Name 'sve' -Value Set-VirtualEnvironment -Scope 'Global'
New-Alias -Name 'nvep' -Value New-VirtualEnvProject -Scope 'Global'

# Convenience functions for toggling Debug and Verbose preferences
Function Switch-DebugPreference {
    $global:DebugPreference = If ($DebugPreference -eq $DBGPref_def) { $DBGPref_alt } Else { $DBGPref_def }
    Write-Host "DebugPreference: [$DebugPreference]"
}
Function Switch-VerbosePreference {
    $global:VerbosePreference = If ($VerbosePreference -eq $VRBPref_def) { $VRBPref_alt } Else { $VRBPref_def }
    Write-Host "VerbosePreference: [$VerbosePreference]"
}
New-Alias -Name 'td' -Value 'Switch-DebugPreference' -Description 'Toggle DebugPreference'
New-Alias -Name 'tv' -Value 'Switch-VerbosePreference' -Description 'Toggle VerbosePreference'
$script:DBGPref_def = 'SilentlyContinue'
$script:DBGPref_alt = 'Continue'
$script:VRBPref_def = 'SilentlyContinue'
$script:VRBPref_alt = 'Continue'

# Additional registry drive
$script:reg = New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR

# Set default output colors
$script:settings = (Get-Host).PrivateData
$settings.WarningForegroundColor = 'Cyan'
$settings.VerboseForegroundColor = 'DarkGreen'
$settings.DebugForegroundColor = 'DarkYellow'

# Set data for the prompt
$script:curr_user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$script:curr_host = [System.Net.Dns]::GetHostName()
# $PString = "{Green:}$($curr_user)@{Yellow:}$($curr_host):{DarkYellow:}$(Get-Path)"

