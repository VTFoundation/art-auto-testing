# AtomicRedTeam Installation ...

# Credits to https://github.com/redcanaryco/atomic-red-team
# Created by @anantkaul

if ($setup -eq "y" -or $setup -eq "Y" -or $setup -eq "yes" -or $setup -eq "YES") {
   # Installing Invoke-Atomic Framework
   Write-Output "`n >> Installing Invoke-Atomic Framework ..." | yellow
   Install-PackageProvider -Name NuGet -Scope CurrentUser -Force
   Install-Module -Name invoke-atomicredteam,powershell-yaml -Scope CurrentUser -Force
   Write-Output "`n >> Successfully Installed Invoke-Atomic Framework ..." | green
   # Getting the atomics
   Write-Output "`n >> Getting the atomics ...`n" | yellow
   Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing); Install-AtomicRedTeam -getAtomics -Force
   Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
   Write-Output " >> Successfully Installed `"Atomic-Red-Team`" in `"C:\AtomicRedTeam\`" ..." | green
   Read-Host -Prompt "`n >> Press enter to continue"
}