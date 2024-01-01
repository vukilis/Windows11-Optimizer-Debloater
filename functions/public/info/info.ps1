# HARDWARE INFO

$ComputerInfo = Get-ComputerInfo

$pcName = $ComputerInfo.CsDNSHostName
$wpf_pcName.Content="Welcome $pcName"

$cpuInfo = $ComputerInfo.CsProcessors
$wpf_cpuInfo.Content=$cpuInfo.Name

Get-CimInstance -ClassName win32_VideoController | ForEach-Object {[void]$wpf_gpuInfo.Items.Add($_.VideoProcessor)}

$ramInfo = get-wmiobject -class Win32_ComputerSystem
$ramInfoGB = [math]::Ceiling($ramInfo.TotalPhysicalMemory / 1024 / 1024 / 1024)
$ramSpeed = Get-WmiObject Win32_PhysicalMemory | Select-Object *
$IsVirtual = $ramInfo.Model.Contains("Virtual")
if ($IsVirtual -like 'False'){
    Write-Output "This Machine is Physical Platform"
    $wpf_ramInfo.Content=[string]$ramInfoGB+"GB"+" "+ $ramSpeed.ConfiguredClockSpeed[0]+"MT/s"
} else{
    Write-Output "This Machine is Virtual Platform"
    $wpf_ramInfo.Content=[string]$ramInfoGB+"GB"
}

$mbInfo = Get-CimInstance -ClassName win32_baseboard | Select-Object *
$wpf_mbInfo.Content=$mbInfo.Product

# OS INFO
$osInfo = $ComputerInfo.OSName
$wpf_osInfo.Content=$osInfo + " " + $ComputerInfo.OsArchitecture

$version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
$verInfo = "Version " + $version + " " + "($($ComputerInfo.OsVersion))"
$wpf_verInfo.Content=$verInfo

$installTimeInfo = $ComputerInfo.OsInstallDate
$wpf_installTimeInfo.Content=$installTimeInfo.ToString('dd-MMM-yyyy HH:mm')

$licenceInfo=Get-CimInstance SoftwareLicensingProduct -Filter "partialproductkey is not null" | Where-Object name -like windows*
$licenceCheckInfo=$licenceInfo.LicenseStatus
if ($licenceCheckInfo -eq 1) {
    $licenceCheckInfo = "Active"
}else {
    $licenceCheckInfo = "Not Active"
}
$wpf_licenceInfo.Content=$licenceCheckInfo

#DISK INFO
Get-Disk | ForEach-Object {[void]$wpf_diskNameInfo.Items.Add($_.FriendlyName)}
function Get-DiskInfo {
    $diskSelected=$wpf_diskNameInfo.SelectedItem
    $details=Get-Disk -FriendlyName "$diskSelected" | Select-Object *
    $wpf_diskStatus.Content=$details.HealthStatus
    $wpf_diskStyle.Content=$details.PartitionStyle
}

$volumes = Get-Volume
foreach ($volume in $volumes) { if ($volume.DriveLetter -notlike "") {[void]$wpf_diskName.Items.Add($volume.DriveLetter)} }
function Get-DiskSize {
    $diskSelected = $wpf_diskName.SelectedItem
    foreach ($volume in $volumes) {
        if ($volume.DriveLetter -eq $diskSelected) {
            $maxSizeGB = $volume.Size / 1GB
            $freeSizeGB = $volume.SizeRemaining / 1GB
            $maxSizeFormatted = if ($maxSizeGB -ge 1000) {
                "{0}TB" -f [math]::Round($maxSizeGB / 1024)
            } else {
                "{0}GB" -f [math]::Round($maxSizeGB)
            }
            $freeSizeFormatted = if ($freeSizeGB -ge 1000) {
                "{0:N1}TB" -f ($freeSizeGB / 1024)
            } else {
                "{0:N1}GB" -f ($freeSizeGB)
            }
            $wpf_diskMaxSize.Content = $maxSizeFormatted
            $wpf_diskFreeSize.Content = $freeSizeFormatted
        }
    }
}