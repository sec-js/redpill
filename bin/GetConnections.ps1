﻿<#
.SYNOPSIS
   Enumerate ESTABLISHED TCP\UDP connections! (IPv4)

   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: netstat, Get-NetAdapter {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.11
   
.DESCRIPTION
   Enumerates ESTABLISHED TCP connections and retrieves the
   Process Name associated from the connection PID identifier.
   
.NOTES
   If used -Action 'verbose' @argument then this cmdlet will
   also list UDP, 0.0.0.0 and 127.0.0.1 (localhost) connections!
   If used -LogFile '$Env:TMP\connections.log' @argument then
   cmdlet will store connections report logfile on %tmp% dir!
   The -Query '@argument' does not search\filter ProcessNames!

.Parameter Action
   Accepts arguments: Enum, Verbose (default: Enum)

.Parameter Query
   Search for a particular string in connections (default: false)

.Parameter LogFile
   The path\name.log of the logfile to create (default: false)

.EXAMPLE
   PS C:\> Get-Help .\GetConnections.ps1 -full
   Access this cmdlet comment based help
    
.EXAMPLE
   PS C:\> .\GetConnections.ps1 -Action Enum
   Enumerates ESTABLISHED TCP connections only!

.EXAMPLE
   PS C:\> .\GetConnections.ps1 -Action Verbose
   Enumerates LISTENNING\ESTABLISHED UDP\TCP connections!

.EXAMPLE
   PS C:\> .\GetConnections.ps1 -Action Enum -Query "13.225.245.57:443"
   Search for '13.225.245.57:443' string in ESTABLISHED TCP connections!

.EXAMPLE
   PS C:\> .\GetConnections.ps1 -Action Verbose -LogFile "$Env:TMP\testme.log"
   Enumerates LISTENNING\ESTABLISHED UDP\TCP connections and store results on testme.log

.OUTPUTS
   Proto LocalAddress  LocalPort RemoteAdress    RemotePort ProcessName PID   State      
   ----- ------------- --------- --------------- ---------- ----------- ---   -----      
   TCP   192.168.1.72  50776     13.225.245.57   443        opera       14492 ESTABLISHED
   TCP   192.168.1.72  53139     142.250.201.80  443        svchost     7280  ESTABLISHED
   TCP   192.168.1.72  55941     20.54.37.64     443        svchost     13224 ESTABLISHED
   TCP   192.168.1.72  56650     2.16.65.56      443        opera       14492 ESTABLISHED
   TCP   192.168.1.72  63127     35.185.44.232   443        opera       14492 ESTABLISHED
   TCP   192.168.1.72  63395     40.115.117.93   443        MsMpEng     3512  ESTABLISHED
   
.LINK
   https://github.com/r00t-3xp10it/redpill
   https://gist.github.com/r00t-3xp10it/bfd266b380b4993014d21881f3bacb90#gistcomment-3837230
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$LogFile="false",
   [string]$Action="Enum",
   [string]$Query="false"
)


$err = $null
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

#Build TCP connections DataTable!
$tcptable = New-Object System.Data.DataTable
$tcptable.Columns.Add("Proto")|Out-Null
$tcptable.Columns.Add("LocalAddress ")|Out-Null
$tcptable.Columns.Add("LocalPort")|Out-Null
$tcptable.Columns.Add("RemoteAdress   ")|Out-Null
$tcptable.Columns.Add("RemotePort")|Out-Null
$tcptable.Columns.Add("ProcessName")|Out-Null
$tcptable.Columns.Add("PID")|Out-Null
$tcptable.Columns.Add("State")|Out-Null

Write-Host ""
#Display Network NetAdapter settings!
Get-NetAdapter | Select-Object Name,Status,LinkSpeed,DeviceID |
Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
   $stringformat = If($_ -Match '(Up)'){
      @{ 'ForegroundColor' = 'DarkCyan' } }Else{ @{ } }
   Write-Host @stringformat $_
}


If($Action -ieq "false" -or $Action -eq $null)
{
   #None @arguments sellected by user!
   Write-Host "[error] None @arguments sellected by user!" -ForeGroundColor Red -BackGroundColor Black
   Write-Host "";Start-Sleep -Seconds 3;Get-Help .\GetConnections.ps1 -Detailed;exit #Exit @GetConnections
}
ElseIf($Action -ieq "verbose")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - netstat enumeration filters!
   #>

   #Detailed Enumeration settings! {exclude: IPv6}
   Write-Host "[i] Listing TCP\UDP ESTABLISHED\LISTENING connections!" -ForeGroundColor Green
   $Filter = "UDP LISTENING ESTABLISHED"     #List LISTENING\ESTABLISHED UDP\TCP connections!
   $Exclude = "[ ::"                         #Exclude from querys IPv6 protocol connections!
}
Else
{
   #Default scan settings! {exclude: UDP|IPv6|LocalHost}
   Write-Host "[i] Listing TCP ESTABLISHED connections!" -ForeGroundColor Green
   $Filter = "ESTABLISHED"                   #List only ESTABLISHED TCP connections!
   $Exclude = "[ :: UDP 0.0.0.0:0 127.0.0.1" #Exclude from querys UDP|IPv6|LocalHost connections!
}


#User query search sellection!
If($Query -ne "false"){$Filter = "$Query";$Exclude = "beterraba"}

#Use netstat to start building the Output Table!
$TcpList = netstat -ano | findstr "$Filter" | findstr /V "$Exclude"
If(-not($TcpList))
{
   Write-Host "[error] None connection(s) found active in $Env:COMPUTERNAME!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "";exit ## Exit @GetConnections
}


ForEach($Item in $TcpList)
{#Loop trougth all $TcpList Items to build Table!

   #Split List using the empty spaces betuiwn strings!
   $parse = $Item.split()

   #Delete empty lines from the variable List!
   $viriato = $parse | ? { $_.trim() -ne "" }

   $Protocol = $viriato[0]             ## Protocol
   $AddrPort = $viriato[1]             ## LocalAddress + port
   $LocalHos = $AddrPort.Split(':')[0] ## LocalAddress
   $LocalPor = $AddrPort.Split(':')[1] ## LocalPort
   $ProcPPID = $viriato[-1]            ## Process PID
   $Remoteal = $viriato[2]             ## RemoteAddress + port

   If($Remoteal -iNotMatch '^(LISTENING|ESTABLISHED)$' -or $Remoteal -ne $null)
   {
      $Remotead = $Remoteal.Split(':')[0] ## RemoteAddress
      $Remotepo = $Remoteal.Split(':')[1] ## RemotePort
   }
   Else
   {
      $Remoteal = "";$Remotead = "";$Remotepo = ""
   }

   try{## Get each process name Tag by is PID identifier! {silent}
      $ProcName = (Get-Process -PID "$ProcPPID" -EA SilentlyContinue).ProcessName
   }catch{} ## Catch exeptions - Do Nothing!

   If($Item -iMatch 'ESTABLISHED')
   {
      $portstate = "ESTABLISHED"
   }
   ElseIf($Item -iMatch 'LISTENING')
   {
      $portstate = "LISTENING"
   }

   ## Adding values to output DataTable!
   $tcptable.Rows.Add("$Protocol",   ## Protocol
                      "$LocalHos",   ## LocalAddress
                      "$LocalPor",   ## LocalPort
                      "$Remotead",   ## RemoteAddress
                      "$Remotepo",   ## RemotePort
                      "$ProcName",   ## ProcessName
                      "$ProcPPID",   ## PID
                      "$portstate"   ## state
   )|Out-Null

}## End of 'ForEach()' loop function!


<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Diplay connections DataTable!

.NOTES
   Out-String formats strings containing the ports '20,23,80,107,137' and
   'ssh', 'lsass', 'System', 'wininit', 'telnet','TeamViewer' and 'MsMpEng'
   Process Names as yellow foregroundcolor in Table output!
#>
$tcptable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
   $stringformat = If($_ -Match '(\s+20\s+|\s+23\s+|\s+80\s+|\s+107\s+|\s+137\s+)' -or
   $_ -iMatch '(\s+ssh\s+|\s+TeamViewer\s+|\s+lsass\s+|\s+System\s+|\s+wininit\s+|\s+telnet\s+|\s+MsMpEng\s+)'){
      @{ 'ForegroundColor' = 'Yellow' } }Else{ @{ 'ForegroundColor' = 'White' } }
   Write-Host @stringformat $_
}


If($Action -ieq "verbose")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Resolve all host IP address to DNS names!
   #>

   #Build DNSHost connections DataTable!
   $dnstable = New-Object System.Data.DataTable
   $dnstable.Columns.Add("RemoteAddress")|Out-Null
   $dnstable.Columns.Add("DnsHostName")|Out-Null

   #Resolve all hosts IP addresses to DNS names!
   $DnsHostsList = (Get-NetTCPConnection -State ESTABLISHED -EA SilentlyContinue).RemoteAddress
   ForEach($TokenItem in $DnsHostsList)
   {
      #Adding values to output DataTable!
      $ResolveNames = (Resolve-DnsName $TokenItem).NameHost
      $filterStream = $ResolveNames[0] + " " + $ResolveNames[1]
      $dnstable.Rows.Add("$TokenItem",    ## RemoteAddress
                         "$filterStream"  ## DnsHostName
      )|Out-Null
   }

   #Diplay DNS RESOLVED HOSTNAMES!
   $dnstable | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match 'DnsHostName'){
         @{ 'ForegroundColor' = 'Green' } }Else{ @{ } }
      Write-Host @stringformat $_
   }

}


If($LogFile -ne "false")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create report logfile!
      
   .NOTES
      If the input Path does not exist then cmdlet
      will try to create the logfile.log on %tmp%
   #>
   
   If($LogFile -iNotMatch '\\')
   {
      Write-Host "[error] -LogFile '<string>' parameter bad input!" -ForegroundColor Red -BackgroundColor Black
      Start-Sleep -Milliseconds 400;Write-Host "[  *  ] Defaulting Path to: '`$Env:TMP\GetConnections.log'" -ForegroundColor Yellow
      $AbsoluctPath = "$Env:TMP\GetConnections.log"
      $err = "True"
   }
   Else
   {
      #Make sure the input path exists!   
      $RawName = $LogFile.Split('\\')[-1]              ## GetConnections.log
      $AbsoluctPath = $LogFile -replace "$RawName",""  ## C:\Users\pedro\Desktop\
      If(-not(Test-Path -Path "$AbsoluctPath" -EA SilentlyContinue))
      { 
         Write-Host "[error] '$AbsoluctPath' directory tree not found!" -ForegroundColor Red -BackgroundColor Black
         Start-Sleep -Milliseconds 400;Write-Host "[  *  ] Defaulting Path to: '`$Env:TMP\GetConnections.log'" -ForegroundColor Yellow
         $AbsoluctPath = "$Env:TMP\GetConnections.log"
         $err = "True"
      }
      Else
      {
         $err = "False"
         $AbsoluctPath = "$LogFile"
      }

   }

   #Creating logfile!
   $tcptable | Format-Table -AutoSize | Out-File -FilePath "$AbsoluctPath" -Force
   If($Action -ieq "verbose"){echo $displayStatisticsTable >> $AbsoluctPath}

   Start-Sleep -Milliseconds 300
   If($err -ieq "True"){$banner = "[  *  ]"}Else{$banner = "[i]"}
   Write-Host "$banner Created logfile in: $AbsoluctPath ..`n" -ForegroundColor Green

}