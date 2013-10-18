Import-Module posh-git

Function Prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    $currPath = Split-Path (Get-Location) -Leaf
    Write-Host ($curr_user) -nonewline -foregroundcolor Green
    Write-Host "@" -nonewline
    Write-Host ($curr_host) -nonewline -foregroundcolor Yellow
    Write-Host ":" -nonewline
    Write-Host ($currPath) -nonewline -foregroundcolor DarkYellow
    Write-VcsStatus

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

# Additional registry drive
$reg = New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR

# Set data for the prompt
$curr_user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$curr_host = [System.Net.Dns]::GetHostName()
# $PString = "{Green:}$($curr_user)@{Yellow:}$($curr_host):{DarkYellow:}$(Get-Path)"
$global:GitPromptSettings.WorkingForegroundColor = [ConsoleColor]::Red
$global:GitPromptSettings.UntrackedForegroundColor = [ConsoleColor]::Red

Enable-GitColors
Start-SshAgent -Quiet
