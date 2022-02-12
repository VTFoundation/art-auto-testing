# AtomicRedTeam FIN6 Cleanup ...

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

$date_time = Get-Date -Format "MM:dd:yyyy_HH:mm"
$date_time = $date_time.Replace(':', "-")
cls

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

$cleanup_dir = "$res_loc\ART_Results\Cleanups"

if (Test-Path $cleanup_dir) {
} else {
  mkdir $cleanup_dir > 1.md; rm 1.md
}
# $cl = "$cleanup_dir\cleanup_FIN6.txt"

$c = 0
foreach ($tid in $fin6) {
    Write-Output "`n[******** BEGIN TEST-$tid CLEANUP *******]" | Tee-Object -file $cleanup_dir\$date_time.txt -Append | yellow
    powershell.exe Invoke-AtomicTest $fin6[$c][0] -TestNumbers $fin6[$c][1] -Cleanup | Add-Content $cleanup_dir\temp.txt
    cat $cleanup_dir\temp.txt
    cat $cleanup_dir\temp.txt >> $cleanup_dir\$date_time.txt
    rm $cleanup_dir\temp.txt
    Write-Output "[!!!!!!!! END  TEST-$tid CLEANUP !!!!!!!]" | Tee-Object -file $cleanup_dir\$date_time.txt -Append | yellow
}

Write-Output "`n >> Cleanup Logs stored in `"$cleanup_dir\$date_time.txt`" ...`n" | green