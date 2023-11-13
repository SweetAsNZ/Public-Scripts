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
    

    if(-not (Test-Path $BasePath) ){
        Write-Host -f Green "Creating $($BasePath)"
        New-Item $BasePath -ItemType Directory
    }

    
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
    }
    catch
    {
        Write-Host "$($ComputerName) TCP/$($Port1) is not available" -ForegroundColor Red
    }
    finally
    {
        $waitHandle.Close()
    }
        
    
    #Port2
    if($null -ne $Port2 -and $Port2 -ne "")
    {
        
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
        }
        catch
        {
            Write-Host "$($ComputerName) TCP/$($Port2) is not available" -ForegroundColor Red
        }
        finally
        {
            $waitHandle.Close()
        }

    }#END IF


    #Port3
    if($null -ne $Port3 -and $Port3 -ne "")
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
        }
        catch
        {
            Write-Host "$($ComputerName) TCP/$($Port3) is not available" -ForegroundColor Red
        }
        finally
        {
            $waitHandle.Close()
        }
        
    }#END IF


}#END FUNCTION

