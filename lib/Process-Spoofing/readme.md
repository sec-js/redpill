## Module Name
   <b><i>PPIDSpoof.ps1</i></b>

|Function name|Description|Privileges|Notes|
|---|---|---|---|
|PPIDSpoof|Creates a process as a child of a specified process ID.<br />Technique ID: T1134.004 (Access Token Manipulation: Parent PID Spoofing)|User Land|[Screenshot](https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/PPIDSpoof.png)|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/PPIDSpoof.ps1" -OutFile "PPIDSpoof.ps1"
```

```powershell
Import-Module -Name ".\PPIDSpoof.ps1" -Force
```

<br />

Spawns a notepad.exe process as a child of the current process.
```powershell
Start-ATHProcessUnderSpecificParent -ParentId $PID -FilePath notepad.exe
```

Spawns a notepad.exe process as a child of the first explorer.exe process.
```powershell
Get-Process -Name explorer | Select-Object -First 1 | Start-ATHProcessUnderSpecificParent -FilePath notepad.exe
```

Creates a notepad.exe process and then spawns a powershell.exe process as a child of it.
```powershell
Start-Process -FilePath $Env:windir\System32\notepad.exe -PassThru | Start-ATHProcessUnderSpecificParent -FilePath powershell.exe -CommandLine '-Command Write-Host foo'
```

<br />

## Module Name
   <b><i>SelectMyParent.exe</i></b>

|Binary name|Description|Privileges|Notes|
|---|---|---|---|
|SelectMyParent|Creates a process as a child of a specified process ID.<br />Technique ID: T1134.004 (Access Token Manipulation: Parent PID Spoofing)|Administrator|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/SelectMyParent.exe" -OutFile "SelectMyParent.exe"
```

```powershell
.\SelectMyParent.exe <process-to-use> <pid-to-spoof>

# Spawn notepad.exe using id 32 (calculator)
.\SelectMyParent.exe notepad 32
```

<br />


## Module Name
   <b><i>spoof.exe</i></b>

|Binary name|Description|Privileges|Notes|
|---|---|---|---|
|spoof|Creates a process as a child of a specified process ID.<br />Technique ID: T1134.004 (Access Token Manipulation: Parent PID Spoofing)|Administrator|\*\*\*|

```powershell
iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/Process-Spoofing/spoof.exe" -OutFile "spoof.exe"
```

```powershell
.\spoof.exe <process-to-use> <pid-to-spoof>
.\spoof.exe pentestlab.exe 1116
```