<#
.Synopsis
   Use a DOT NET Method to Fast Test a Given Port For All Servers in AD
.DESCRIPTION
   
.EXAMPLE
   Test-PortFast -ComputerName Server1 -Port 3389
.EXAMPLE
   Test-PortFast -ComputerName Server1 -Port 3389 -Port2 5985 -Port3 5986
#>
function Test-PortFast
{

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Port,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int]$Port2,
        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int]$Port3,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$ComputerName
    )
    

    #Requires -Modules ActiveDirectory


    $ErrorActionPreference = 'STOP' # Allows Try/Catch Blocks to Work


    $Title      = "Test-PortFast"
    $BasePath   = "C:\SCRIPTS\Network\$($Title)"
    $ScriptPath = (Join-Path $Basepath $Title)
    
    $Works1Txt = ($ScriptPath + "_Works_$($Port).txt")
    $Fails1Txt = ($ScriptPath + "_Fails_$($Port).txt")
    $Works2Txt = ($ScriptPath + "_Works_$($Port2).txt")
    $Fails2Txt = ($ScriptPath + "_Fails_$($Port2).txt")
    $Works3Txt = ($ScriptPath + "_Works_$($Port3).txt")
    $Fails3Txt = ($ScriptPath + "_Fails_$($Port3).txt")


    if(-not (Test-Path $BasePath) ){
        Write-Host -f Green "Creating $($BasePath)"
        New-Item $BasePath -ItemType Directory
    }

    
    # Delete Existing Output Files
    $Txts = @("$Works1Txt","$Fails1Txt","$Works2Txt","$Fails2Txt","$Works3Txt","$Fails3Txt")
    foreach ($Txt in $Txts)
    {
        if(Test-Path $Txt){
            Remove-Item $Txt -Confirm:$false
        }
    }
    

    $Port1Works = @()
    $Port1Fails = @()
    $Port2Works = @()
    $Port2Fails = @()
    $Port3Works = @()
    $Port3Fails = @()


    #Port1
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $asyncResult = $tcpClient.BeginConnect($ComputerName, $Port, $null, $null) # If Querying AD
    $waitHandle = $asyncResult.AsyncWaitHandle

    try
    {
        if (!$waitHandle.WaitOne(50, $false)) # Timeout set to 50 ms
        {
            $tcpClient.Close()
            throw "Connection timed out."
        }

        $tcpClient.EndConnect($asyncResult)
        Write-Host "$($ComputerName) TCP/$($Port) is available" -ForegroundColor Green
        $Port1Works += ($ComputerName + " - TCP/$($Port)")
        Add-Content $Works1Txt -Value ($ComputerName + " - TCP/$($Port) - SUCCESS")
    }
    catch
    {
        Write-Host "$($ComputerName) TCP/$($Port1) is not available" -ForegroundColor Red
        $Port1Fails += ($ComputerName + " - TCP/$($Port)")
        Add-Content $Fails1Txt -Value ($ComputerName + " - TCP/$($Port) - FAILED")
    }
    finally
    {
        $waitHandle.Close()
    }
        
    
    Add-Content $Works1TXT -Value ("`r`nRun From: $($ENV:COMPUTERNAME) $($ScriptPath).ps1 `r`n")
    Add-Content $Fails1Txt -Value ("`r`nRun From: $($ENV:COMPUTERNAME) $($ScriptPath).ps1 `r`n")



    #Port2
    if($null -ne $Port2)
    {
        
        Write-Host "######### PORT $($Port2) #########`n"

        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $tcpClient.BeginConnect($ComputerName, $Port2, $null, $null) # If Querying AD
        $waitHandle = $asyncResult.AsyncWaitHandle

        try
        {
            if (!$waitHandle.WaitOne(50, $false)) # Timeout set to 50 ms
            {
                $tcpClient.Close()
                throw "Connection timed out."
            }

            $tcpClient.EndConnect($asyncResult)
            Write-Host "$($ComputerName) TCP/$($Port2) is available" -ForegroundColor Green
            $Port2Works += ($ComputerName + "TCP/$($Port2)")
            Add-Content $Works2TXT -Value ($ComputerName + " - TCP/$($Port) - SUCCESS")
        }
        catch
        {
            Write-Host "$($ComputerName) TCP/$($Port2) is not available" -ForegroundColor Red
            $Port2Fails += ($ComputerName + "TCP/$($Port2)")
            Add-Content $Fails2Txt -Value ($ComputerName + " - TCP/$($Port) - FAILED")
        }
        finally
        {
            $waitHandle.Close()
        }

        Add-Content $Works2TXT -Value ("`r`nRun From: $($ENV:COMPUTERNAME) $($ScriptPath).ps1 `r`n")
        Add-Content $Fails2Txt -Value ("`r`nRun From: $($ENV:COMPUTERNAME) $($ScriptPath).ps1 `r`n")

    }#END IF


    #Port3
    if($null -ne $Port3)
    {

        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $tcpClient.BeginConnect($ComputerName, $Port3, $null, $null) # If Querying AD
        $waitHandle = $asyncResult.AsyncWaitHandle

        try
        {
            if (!$waitHandle.WaitOne(50, $false)) # Timeout set to 50 ms
            {
                $tcpClient.Close()
                throw "Connection timed out."
            }

            $tcpClient.EndConnect($asyncResult)
            Write-Host "$($ComputerName) TCP/$($Port3) is available" -ForegroundColor Green
            $Port3Works += ($ComputerName + "TCP/$($Port3)")
            Add-Content $Works3TXT -Value ($ComputerName + " - TCP/$($Port) - SUCCESS")
        }
        catch
        {
            Write-Host "$($ComputerName) TCP/$($Port3) is not available" -ForegroundColor Red
            $Port3Fails += ($ComputerName + "TCP/$($Port3)")
            Add-Content $Fails3Txt -Value ($ComputerName + " - TCP/$($Port) - FAILED")
        }
        finally
        {
            $waitHandle.Close()
        }

        Add-Content $Works3TXT -Value ("`r`nRun From: $($ENV:COMPUTERNAME) $($ScriptPath).ps1 `r`n")
        Add-Content $Fails3Txt -Value ("`r`nRun From: $($ENV:COMPUTERNAME) $($ScriptPath).ps1 `r`n")

        $RDPFails

    }#END IF


}#END FUNCTION

