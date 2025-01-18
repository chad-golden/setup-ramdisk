Write-Host "::debug::Working directory is: $PWD"

if (-not $IsWindows) {
  throw "This action requires Windows."
}

Write-Host "::debug::DRIVE_LETTER: $($env:IMAGE_FILE_PATH)"

Write-Host "Dismounting $($env:DRIVE_LETTER):..."
& 'C:\Windows\System32\imdisk.exe' -d -m "$($env:DRIVE_LETTER):"
Write-Host "Dismount complete"