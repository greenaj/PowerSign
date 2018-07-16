$timeStampers = $null
$thumbprint = $null

[int]$stampIdx = 0

function GetTsUrl() {
    [string]$retVal = $script:timeStampers[$script:stampIdx]
    $script:stampIdx = ($script:stampIdx + 1) % $timeStampers.Length

    return  $retVal
}

function SignFile([string]$File) {
    $tsUrl = GetTsUrl
    [void] (signtool sign /sha1 $thumbprint /fd SHA256 /tr $tsUrl ""$File"")
    return $LASTEXITCODE
}

function GetConfigDir() {
    Join-Path -Path $env:LOCALAPPDATA -ChildPath "PowerSign"
}

function InitConfigDir() {
    $configDir = GetConfigDir
    if (!(Test-Path $configDir -PathType Container)) {
        New-Item -Path $configDir -ItemType Directory
    }
    return $configDir
}

function LoadConfig([string]$ConfigName) {
    $config = Import-PowerShellDataFile -Path "$(GetConfigDir)\$($ConfigName).psd1"
    $script:timeStampers = $config.timeStampers
    $script:thumbprint = $config.thumbprint
}

<#
.SYNOPSIS

Addes a config file to be used for code signing.

.PARAMETER File

The PowerShell data file containing the configuration.

.PARAMETER Name

A logical name for the configration, it does not need to mach the file name.

.EXAMPLE

Add-Config -File MyConfig.psd1 -Name ForQA

.NOTES

This will copy the config specified by -File into the user's %LOCALAPPDADA% directory, changing the name
to the value of the -Name paramter followed by .psd1 .

A sambple config is show below:

@{
    # list as many rfc3161 timestamping urls as designed.
    timeStampers = @(   "http://timestamp.globalsign.com/scripts/timstamp.dll",
                        "http://tsa.startssl.com/rfc3161",
                        "http://timestamp.comodoca.com/?td=sha256",
                        "http://sha256timestamp.ws.symantec.com/sha256/timestamp"
    )

    # Set this to a thumbprint of you code signing certificate.
    thumbprint  = "b6b248ff8ab1bf545d3f8db6c2695a6863f4bb3c"
}

#>
function Add-Config {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [string]$File,

        [parameter(Mandatory=$true)]
        [string]$Name
    )
    BEGIN {
        $configDir = InitConfigDir
    }
    PROCESS {
        Copy-Item -Path $File -Destination (Join-Path -Path $configDir -ChildPath "$($Name).psd1")
    }
}

<#
.SYNOPSIS

Calls Microsoft's signtool.exe code signing utility repeatedly until it succeeded, cycling through a list
of timestamper URLs for each attempt.

.DESCRIPTION

Most often, timespamping succeeds, but at times code siging fails in builds because the call for timestamping fails
and the failure is not on the part of the caller, but the timestamper. Fow whatever reason, it may be busy or other
error occurs.

Set-Sig will attemplt, upto the number specified by Attempts, to sign a particular file, cycling through a list of
timespamping URLs each signing attempt.

.PARAMETER File

File to sign. Can be a full or relative path.

.PARAMETER ConfigName

Name of saved configuration, see Add-Config, that contains a list of timestamp URLs and certificate hash.

.PARAMETER Attempts

Max number of attempts that will be made.

#>
function Set-Sig {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [string]$File,

        [parameter(Mandatory=$true)]
        [string]$ConfigName,

        [int]$Attempts = 300
    )
    BEGIN {
        [void] (Get-Command "signtool.exe")
        [void] (LoadConfig $ConfigName)
    }
    PROCESS {
        [int]$lastExit = -1
        [int]$thisAttempt = 1
        while ($lastExit -ne 0) {
            if ($thisAttempt -gt $Attempts) {
                break
            }
            $lastExit = SignFile $File
            $thisAttempt++
        }
        $lastExit
    }
}

Export-ModuleMember -Function Add-Config
Export-ModuleMember -Function Set-Sig
