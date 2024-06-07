# Define variables
$DownloadPath = "$env:USERPROFILE\Downloads\notwindows.iso"
$DriveLetter = Read-Host "DriveLetter"  

# Choose Distribution 
$Choices = @("Arch", "Ubuntu", "Debian")

# Display the Choices to the user
Write-Host "Please choose from the following options:"
for ($i = 0; $i -lt $Choices.Length; $i++) {
    Write-Host "$($i + 1). $($Choices[$i])"
}

# Prompt the user for their selection
$Selection = Read-Host "Enter the number of your choice"

# Validate the input and convert it to the corresponding option
if ($Selection -match '^\d+$' -and $Selection -gt 0 -and $Selection -le $Choices.Length) {
    $ChosenOption = $Choices[$Selection - 1]
    Write-Host "You selected: $ChosenOption"
    $Distro = $ChosenOption
} else {
    Write-Host "Invalid selection. Please enter a number between 1 and $($Choices.Length)."
}

# Function to download the latest Arch Linux ISO
function Download-LinuxISO {
	if ( $Distro -eq 'Arch' )
{
	$IsoUrl = "https://packages.oth-regensburg.de/archlinux/iso/latest/archlinux-x86_64.iso"
}
if ( $Distro -eq 'Ubuntu' )
{
	$IsoUrl = "https://ftp.halifax.rwth-aachen.de/ubuntu-releases/noble/ubuntu-24.04-desktop-amd64.iso"
}
if ( $Distro -eq 'Debian' )
{
	$IsoUrl = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
}

    Write-Output "Downloading the latest $Distro Linux ISO from $IsoUrl..."
    $wc = New-Object net.webclient
    $wc.Downloadfile($IsoUrl, $DownloadPath)
    Write-Output "Downloaded $Distro ISO to $DownloadPath"
}

# Function to prepare the USB drive
function Prepare-USBDrive {
    Write-Output "Preparing USB drive $DriveLetter..."
    $DiskPartScript = @"
select volume D
clean
create partition primary
active
format fs=fat32 quick
assign letter=D
exit
"@
    $DiskPartScript | Out-File -FilePath "$env:TEMP\diskpart_script.txt" -Encoding ASCII
    Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$env:TEMP\diskpart_script.txt`"" -Wait -NoNewWindow
    Write-Output "USB drive $DriveLetter prepared successfully."
}

# Function to extract ISO to USB drive
function ExtractISOToUSB {
    param (
        [string]$IsoPath,
        [string]$DriveLetter
    )
    Write-Output "Extracting ISO to USB drive $DriveLetter..."
    $SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    if (-Not (Test-Path $SevenZipPath)) {
        Write-Error "7-Zip is not installed. Please install 7-Zip and try again."
        exit
    }
    & Invoke-Expression -Command ('. "{0}" x {1} -o{2}:\' -f "$SevenZipPath", $DownloadPath, $Driveletter)
    Write-Output "ISO extracted to USB drive $DriveLetter successfully."
}

# Main script execution
Download-LinuxISO
Prepare-USBDrive -driveLetter $DriveLetter
ExtractISOToUSB -isoPath $DownloadPath -driveLetter $DriveLetter

Write-Output "Bootable $Distro Linux USB drive created successfully."
