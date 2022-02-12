# ART-auto-testing
Lets define ART, atomic Red Team.
Credits to https://github.com/redcanaryco/atomic-red-team
For information about the philosophy and development of Atomic Red Team, visit a website at https://atomicredteam.io

--- VTFoundation contribution ---
These scripts are developed to run atomic red team testing automatically to test the controls. There are 2 components to it.
First, to install the invoke framework (https://github.com/redcanaryco/invoke-atomicredteam). You can manually do it or our script will do it for you.
Second, to run the TIDs one by one manually or run ALL automated using our script.

Getting Started
The easiest way to start with automated atomic red tests are to follow the following commands:
1. Run powershell as an admin and type this command.
``` powershell
Set-ExecutionPolicy RemoteSigned
```

2. Run powershell (admin or not) and type this command which will install invoke framework and will ask you for which or ALL TIDs to run.
``` powershell
curl https://raw.githubusercontent.com/VTFoundation/atomic-red-team/main/script-win.ps1 -o auto-ART.ps1; .\auto-ART.ps1
```

Decision making during the script:
1. Invoke framkework install?
2. Which TIDs to run (e.r. T1070) or ALL
3. Clean up

## ART.bat
```powershell
curl https://raw.githubusercontent.com/VTFoundation/art-auto-testing/main/ART.bat -o ART.bat; .\ART.bat
```
