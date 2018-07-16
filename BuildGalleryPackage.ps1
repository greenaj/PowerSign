# Adapted from https://github.com/pester/Pester project for building gallery pacakge.

$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'
$baseDir = $PSScriptRoot

try
{
    $buildDir = "$baseDir\build\psgallery\PowerSign"
    if (Test-Path $buildDir) {
        Write-Verbose 'Removing build folder'
        Remove-Item -LiteralPath $buildDir -Recurse -Force -Confirm:$false -Verbose
    }

    $null = New-Item -Path $buildDir -ItemType Directory -Verbose

    Write-Verbose "Copying release files to build folder '$buildDir'"
    Copy-Item $baseDir\PowerSign.ps?1       $buildDir\
    Copy-Item $baseDir\ExampleConfig.psd1   $buildDir\
    Copy-Item $baseDir\LICENSE              $buildDir\

    Write-Verbose 'Copy complete. Contents:'
    Get-ChildItem $buildDir -Recurse | Out-Host
}
catch
{
    Write-Error -ErrorRecord $_
    exit 1
}