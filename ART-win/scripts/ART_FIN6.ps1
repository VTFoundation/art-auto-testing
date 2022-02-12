# PI.ps1

# Windows ART
# Credits to https://github.com/redcanaryco/atomic-red-team
# Created by @anantkaul

$res_loc = "C:\AtomicRedTeam\VTF"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
Remove-Item $env:TEMP\svchost-exe.dmp -ErrorAction Ignore

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   $arguments = "& '" +$myinvocation.mycommand.definition + "'"
   Start-Process powershell -Verb runAs -ArgumentList $arguments
   Break
} 

function green {
   process { Write-Host $_ -ForegroundColor Green }
}
function yellow {
   process { Write-Host $_ -ForegroundColor Yellow }
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

$date_time = Get-Date -Format "MM:dd:yyyy_HH:mm"
$date_time = $date_time.Replace(':', "-")
cls

## Change Technique IDs and TestNumbers in the format 'T1003 -TestNumbers 1,2,3', .... 
$fin6 = @(('T1078.001', 1),
          ('T1059.001', 1),
          ('T1059.001', 2),
          ('T1059.001', 6),
          ('T1059.001', 9),
          ('T1059.001', 11),
          ('T1059.001', 13),
          ('T1047.001', 1),
          ('T1047.001', 4),
          ('T1047.001', 7),
          ('T1047.001', 8),
          ('T1134.001', 1),
          ('T1134.004', 4),
          ('T1027.001', 1),
          ('T1027.001', 4),
          ('T1027', 3),
          ('T1027', 4),
          ('T1027', 5),
          ('T1027', 8),
          ('T1046', 3),
          ('T1046', 4),
          ('T1018', 1),
          ('T1018', 2),
          ('T1018', 3),
          ('T1018', 4),
          ('T1018', 5),
          ('T1018', 8),
          ('T1018', 10),
          ('T1018', 11),
          ('T1056.001', 1),
          ('T1056.001', 2),
          ('T1119', 1),
          ('T1119', 3))

$present_dir = "$res_loc\ART_Results\$date_time"
$c = 0

foreach ($tid in $fin6) {

   $check_pre = powershell.exe "Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -CheckPrereqs" | sls "-GetPrereqs"
   $ele_req = powershell.exe "cat $present_dir\get_preq.md | sls `"Elevation required`""

   if (Test-Path $present_dir) {
      # Write-Output " >> Previous AtomicTest Overwriting and Updating with the Latest AtomicTest ..."
   } else {
      mkdir $present_dir > 1.md; rm 1.md
   }

   try {

      Write-Output "`n[******** BEGIN TID-$tid Brief Details *******]" | Tee-Object -file $present_dir\Brief_Details.txt -Append | yellow
      powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -ShowDetailsBrief | Add-Content $present_dir\Brief_Details_temp.txt
      cat $present_dir\Brief_Details_temp.txt
      cat $present_dir\Brief_Details_temp.txt >> $present_dir\Brief_Details.txt
      rm $present_dir\Brief_Details_temp.txt
      Write-Output "[!!!!!!!! END TID-$tid Brief Details !!!!!!!]" | Tee-Object -file $present_dir\Brief_Details.txt -Append | yellow

      Write-Output "`n[******** BEGIN TID-$tid Full Details *******]" | Tee-Object -file $present_dir\Full_Details.md -Append | yellow
      powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -ShowDetails | Add-Content $present_dir\Full_Details_temp.md
      cat $present_dir\Full_Details_temp.md
      cat $present_dir\Full_Details_temp.md >> $present_dir\Full_Details.md
      rm $present_dir\Full_Details_temp.md
      Write-Output "[!!!!!!!! END TID-$tid Full Details !!!!!!!]" | Tee-Object -file $present_dir\Full_Details.md -Append | yellow

      # Try installing the dependencies first ...
      powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -GetPrereqs -Force # | Add-Content $present_dir\get_preq.md
      Write-Output "`n[******** BEGIN ATOMIC TEST TID-$tid *******]" | Tee-Object -file $present_dir\Output.md -Append | yellow            
      powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -CheckPrereqs
      powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -ExecutionLogPath `"$present_dir\Logs.csv`" | Add-Content $present_dir\Output_temp.md
      # rm $present_dir\get_preq.md

      if (Test-Path $HOME\Desktop\open-ports.txt) {
        mv $HOME\Desktop\open-ports.txt $present_dir\Open_Ports.txt
      }

      cat $present_dir\Output_temp.md
      cat $present_dir\Output_temp.md >> $present_dir\Output.md
      rm $present_dir\Output_temp.md
      Write-Output "[!!!!!!!! END ATOMIC TEST TID-$tid !!!!!!!]" | Tee-Object -file $present_dir\Output.md -Append | yellow

      Write-Output "`n >> AtomicTest $tid Completed Successfully !!" | green
      Write-Output " >> Results Stored in `"$present_dir`" ...`n" | green
   } catch {
   Write-Output "`n >> An unexpected Error occured. Try again later ...`n"
   }   

   $c++
}