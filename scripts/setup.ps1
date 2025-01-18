function Write-ActionDebug {
  param(
    [Parameter(Mandatory = $true)]
    [object]$Text
  )
  
  $stringText = $Text | Out-String
  $stringText -split '\r?\n' | Where-Object { $_ } | ForEach-Object {
    Write-Host "::debug::$_"
  }
}

Write-Host "::debug::Installation working directory is: $PWD"

if (-not $IsWindows) {
  throw "This action requires Windows."
}

$needsInstall = ($null -eq (Get-Command imdisk -ErrorAction SilentlyContinue))
Write-ActionDebug "Imdisk needs to be installed? $needsInstall"

$doInstall = ($env:INSTALL_IMDISK -eq 'true') -and $needsInstall
if ($doInstall) {
  $workingDriveLetter = Split-Path $env:GITHUB_WORKSPACE -Qualifier
  $workingFolder = "$workingDriveLetter\$([System.Guid]::NewGuid().ToString())"
  New-Item -Path $workingFolder -ItemType Directory | Out-Null
  Push-Location $workingFolder

  $installerPath = "$($env:GITHUB_ACTION_PATH)/external/imdisk/imdisk.zip"
  Copy-Item $installerPath -Destination .
  $expectedHash = "0558DDD7B751CC29B4530E5B85F86344A4E4FA5A91D16C5479F0A4470AADEF23"
  $actualHash = (Get-FileHash "imdisk.zip" -Algorithm SHA256).Hash
  if ($actualHash -ne $expectedHash) {
    throw "Hash verification failed!"
  }
  else {
    Write-Host "SHA256 verification of imdisk installation package succeeded"
  }

  Write-Host "Installing ImDisk..."
  $env:IMDISK_SILENT_SETUP = 1
  Expand-Archive -Path "imdisk.zip" -DestinationPath "." | Out-Null
  $installOut = & cmd.exe /c install.cmd 2>&1
  Write-ActionDebug $installOut
  Write-Host 'ImDisk is installed'
}
else {
  Write-Host 'Skipping ImDisk install'
}

$cmd = {
  $sizeParam = $env:SIZE_IN_MB + "M"
  $mountPath = $env:DRIVE_LETTER + ":"

  Write-Host "Setting up RAM drive at $mountPath, size $sizeParam"
  & 'C:\Windows\System32\imdisk.exe' -a -s $sizeParam -m $mountPath -p "/FS:NTFS /Q /Y"
  Write-Host "RAM drive setup complete. Drive is available at $($mountPath)"
}

$imdiskOutput = & $cmd
Write-ActionDebug $imdiskOutput

if ($env:COPY_WORKSPACE -eq 'true') {
  Write-Host 'Copying workspace files...'
  $source = $env:GITHUB_WORKSPACE
  $destination = "$($env:DRIVE_LETTER):\workspace"
  New-Item -ItemType Directory -Path $destination -Force | Out-Null
  $robocopyOutput = & robocopy $source $destination *.* /E /W:1 /R:1 /MT /NFL
  Write-ActionDebug $robocopyOutput

  if ($lastExitCode -lt 8) {
    Write-Host "Workspace files copied to $destination"
    exit 0
  }
  else {
    Write-Host "Failed to copy workspace files to $destination"
  }
}