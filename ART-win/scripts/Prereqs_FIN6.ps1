# PI.ps1

# Windows ART
# Credits to https://github.com/redcanaryco/atomic-red-team
# Created by @anantkaul

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
Remove-Item $env:TEMP\svchost-exe.dmp -ErrorAction Ignore

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   $arguments = "& '" +$myinvocation.mycommand.definition + "'"
   Start-Process powershell -Verb runAs -ArgumentList $arguments
   Break
} 

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
          ('T1027.004', 1),
          ('T1027.004', 4),
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
$c = 0

foreach ($tid in $fin6) {
    powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -GetPrereqs -Force
    $c++
}