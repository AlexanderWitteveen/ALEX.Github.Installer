if (-not (New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
    Start-Process powershell.exe -ArgumentList ("-file", ('"' + "$PSCommandPath" + '"'), "-noexit", "-ExecutionPolicy", "bypass") -Verb RunAs -Wait
    break
}

Write-Output "Installing: $name"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Confirm:$false -Force -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Confirm:$false -Force -Scope CurrentUser

[Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" ) | Out-Null

function CreateFolderRecurse
{
    [cmdletbinding()]
    param (
        [string]$path
    )

    if (Test-Path $path) { return }

    $parent = [System.IO.Path]::GetDirectoryName($path)
    if ($parent.Length -gt 3) { CreateFolderRecurse $parent }

    Write-Verbose ("Create Folder " + $path)
    if (-not (Test-Path $path)) { New-Item -Path $path -ItemType Directory -Force -Confirm:$false | Out-Null }
}

function Unzip
{
    [cmdletbinding()]
    param (
        [string]$SourceText,
        [string]$TargetPath
    )
    #$TargetPath = $env:SystemDrive + "\ALEX" + $TargetPath
    Write-Verbose -Message ("Unzip " + $TargetPath)
    $SourcePath = $TargetPath + ".zip"
    $buffer = [System.Convert]::FromBase64String($SourceText)
    [System.IO.File]::WriteAllBytes($SourcePath, $buffer)
    #[System.IO.Compression.ZipFile]::ExtractToDirectory($SourcePath, $TargetPath)

    $zip = [System.IO.Compression.ZipFile]::OpenRead($SourcePath)
    foreach ($entry in $zip.Entries)
    {
        CreateFolderRecurse -path ([System.IO.Path]::GetDirectoryName([System.IO.Path]::Combine($TargetPath, $entry.FullName)))
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, ([System.IO.Path]::Combine($TargetPath, $entry.FullName)), $true)
    }
    $zip.Dispose()

    Remove-Item $SourcePath -Force
}

function SetModulesPath
{
    [cmdletbinding()]
    param (
        [string]$ModulesPath
    )

    if(-not ($env:PSModulePath.Contains($ModulesPath)) )
    {
        Write-Verbose -Message "Add Environment Variable"
        $env:PSModulePath += ";" + $ModulesPath
        [System.Environment]::SetEnvironmentVariable("PSModulePath", $env:PSModulePath)
    }

    $path = (Get-ItemProperty -Path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "PSModulePath").PSModulePath
    if (-not($path.Contains($ModulesPath)))
    {
        Write-Verbose -Message "Add Registry"
        Set-ItemProperty -Path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "PSModulePath" -Value ($path + ";" + $ModulesPath) -Force
    }
}

$targetpath = $rootfolder + "\" + $targetfolder
$zippath = $targetpath + "\install"
$installpath = $zippath + "\" + $install

CreateFolderRecurse -path $targetpath

Unzip $folder $zippath

if ($install.Length -gt 0) {
    &($installpath)
}

Write-Host "press key..."
Read-Host
