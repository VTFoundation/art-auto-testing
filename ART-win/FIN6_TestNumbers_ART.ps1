# PI.ps1

# Windows ART
# Credits to https://github.com/redcanaryco/atomic-red-team
# Created by @anantkaul

$res_loc = "C:\AtomicRedTeam\VTF"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   $arguments = "& '" +$myinvocation.mycommand.definition + "'"
   Start-Process powershell -Verb runAs -ArgumentList $arguments
   Break
} 

$setup = Read-Host -Prompt "`n >> Do you want to install Atomic-Red-Team [Y/y] or have it installed already [N/n] ?"

function green {
   process { Write-Host $_ -ForegroundColor Green }
}
function yellow {
   process { Write-Host $_ -ForegroundColor Yellow }
}

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

# Checking Invoke-Atomic Framework
if (-not (Test-Path -Path C:\AtomicRedTeam\invoke-atomicredteam)) {
   Write-Output "`n >> Installing Invoke-Atomic Framework ...`n"
   Install-Module -Name invoke-atomicredteam,powershell-yaml -Scope CurrentUser -Force
   Write-Output "`n >> Installed Invoke-Atomic Framework successfully ..." | green
}
# Checking the atomics
if (-not (Test-Path -Path C:\AtomicRedTeam\atomics)) {
   Write-Output "`n >> Getting the atomics ...`n"
   Invoke-Expression (Invoke-WebRequest 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing); Install-AtomicRedTeam -getAtomics -Force
   # Importing the module
   Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force
   Write-Output " >> Successfully Installed `"Atomic-Red-Team`" in `"C:\AtomicRedTeam\`" ..." | green
   Read-Host -Prompt "`n >> Press enter to continue"
}

function Cleanup_atomic($atid) {
   
   $date_time = Get-Date -Format "MM:dd:yyyy_HH:mm"
   $date_time = $date_time.Replace(':', "-")
   $cleanup_dir = "$res_loc\Cleanup_Logs"

   if (Test-Path $cleanup_dir) {
   } else {
      mkdir $cleanup_dir > 1.md; rm 1.md
   }
   $cl = "$cleanup_dir\$date_time.txt"

   for ($element = 0; $element -lt $atid.Count; $element++) {

      $a = $atid[$element]
      $ac = $element + 1

      "`n[********BEGIN TEST-$ac CLEANUP *******]" >> $cl
      powershell.exe "Invoke-AtomicTest $a -Cleanup" >> $cl
      cd Cleanup_Logs
      if ("PermissionDenied:" -match "cat $date_time.txt | sls `"PermissionDenied:`"") {
      # if ('PermissionDenied:' -match "sls -pattern `"PermissionDenied:`" -path `"$cleanup_dir\$date_time.txt`"") {
         Start-Process -Wait -Verb runAs powershell.exe "Invoke-AtomicTest $a -Cleanup" >> $cl
      } else {
         Start-Process -Wait powershell.exe "Invoke-AtomicTest $a -Cleanup" >> $cl
      }
      "[!!!!!!!! END  TEST-$ac CLEANUP !!!!!!!]" >> $cl
   }
   cd ..
   Write-Output " >> Cleanup Logs stored in `"$cl`" ...`n" | yellow
   exit
}
 
 $all_tids = @()
 $c = 0

#  do {
$date_time = Get-Date -Format "MM:dd:yyyy_HH:mm"
$date_time = $date_time.Replace(':', "-")

cls
# $tid = Read-Host -Prompt "`n >> Enter the Technique ID ( with prefix `'T`' ) or type ALL for AtomicTest"

## Change Technique IDs and TestNumbers in the format 'T1003 -TestNumbers 1,2,3', .... 
$fin6 = @('T1078.001 -TestNumbers 1',
          'T1059.001 -TestNumbers 1',
          'T1059.001 -TestNumbers 2',
          'T1059.001 -TestNumbers 6',
          'T1059.001 -TestNumbers 9',
          'T1059.001 -TestNumbers 11',
          'T1059.001 -TestNumbers 13',
          'T1047.001 -TestNumbers 1',
          'T1047.001 -TestNumbers 4',
          'T1047.001 -TestNumbers 7',
          'T1047.001 -TestNumbers 8',
          'T1134.001 -TestNumbers 1',
          'T1134.004 -TestNumbers 4',
          'T1027.004 -TestNumbers 1',
          'T1027.004 -TestNumbers 4',
          'T1027 -TestNumbers 3',
          'T1027 -TestNumbers 4',
          'T1027 -TestNumbers 5',
          'T1027 -TestNumbers 8',
          'T1046 -TestNumbers 3',
          'T1046 -TestNumbers 4',
          'T1018 -TestNumbers 1',
          'T1018 -TestNumbers 2',
          'T1018 -TestNumbers 3',
          'T1018 -TestNumbers 4',
          'T1018 -TestNumbers 5',
          'T1018 -TestNumbers 8',
          'T1018 -TestNumbers 10',
          'T1018 -TestNumbers 11',
          'T1056.001 -TestNumbers 1',
          'T1056.001 -TestNumbers 2',
          'T1119 -TestNumbers 1',
          'T1119 -TestNumbers 3')

# $date_time = Get-Date -Format "dd/MM/yyyy_HH:mm:ss"

foreach ($tid in $fin6) {

    $present_dir = "$res_loc\ART_Results\$date_time\$tid"

    $check_pre = powershell.exe "Invoke-AtomicTest $tid -CheckPrereqs" | sls "-GetPrereqs"
    $get_pre = "Invoke-AtomicTest $tid -GetPrereqs -Force"
    $brief_details = "Invoke-AtomicTest $tid -ShowDetailsBrief"
    $full_details = "Invoke-AtomicTest $tid -ShowDetails"

    if (Test-Path $present_dir) {
    # Write-Output " >> Previous AtomicTest Overwriting and Updating with the Latest AtomicTest ..."
    } else {
    mkdir $present_dir > 1.md; rm 1.md
    }      

    try {
    powershell.exe $brief_details | Out-File $present_dir\Brief_Details.txt
    powershell.exe $full_details | Out-File $present_dir\Full_Details.md
    Remove-Item $env:TEMP\svchost-exe.dmp -ErrorAction Ignore
    if ($check_pre -match "-GetPrereqs") {
        # Try installing the dependencies first ...
        powershell.exe $get_pre | Out-File $present_dir\get_preq.md
        if (powershell.exe "cat $present_dir\get_preq.md | sls `"Elevation required`"" -match "Elevation required") {
            Start-Process powershell.exe "Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; Invoke-AtomicTest $tid -CheckPrereqs; powershell.exe `"Invoke-AtomicTest $tid -ExecutionLogPath `"$present_dir\Logs.txt`"`" | Out-File $present_dir\Output.md" -Wait -Verb runAs
        } else {
            Start-Process -Wait powershell.exe "Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; Invoke-AtomicTest $tid -CheckPrereqs; powershell.exe `"Invoke-AtomicTest $tid -ExecutionLogPath `"$present_dir\Logs.txt`"`" | Out-File $present_dir\Output.md"
        } 
        rm $present_dir\get_preq.md
    } else {
        Start-Process -Wait powershell.exe "Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; Invoke-AtomicTest $tid -CheckPrereqs; powershell.exe `"Invoke-AtomicTest $tid -ExecutionLogPath `"$present_dir\Logs.txt`"`" | Out-File $present_dir\Output.md"
    }

    if (Test-Path $HOME\Desktop\open-ports.txt) {
        mv $HOME\Desktop\open-ports.txt $present_dir\Open_Ports.txt
    }
    
    Write-Output "`n >> AtomicTest $tid Completed Successfully !!" | green
    Write-Output " >> Results Stored in `"$present_dir`" ...`n" | yellow
    } catch {
    Write-Output "`n >> An unexpected Error occured. Try again later ...`n"
    }
    
    $all_tids += $tid
    $c++
}
$condition = Read-Host -Prompt " >> Do you want to exit [Y/y] or proceed with a complete cleanup [N/n] ?"
# Cleanup for [n] and [y] to continue ...

if ($condition -eq "n" -or $condition -eq "N" -or $condition -eq "no" -or $condition -eq "NO") {
    Cleanup_atomic($all_tids)
}
#  } while ($condition -eq "y" -or $condition -eq "Y" -or $condition -eq "yes" -or $condition -eq "YES")
 
Read-Host -Prompt " >> Press enter to exit"
