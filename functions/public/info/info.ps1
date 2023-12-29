# HARDWARE INFO
$pcName=[System.Net.Dns]::GetHostName()
$wpf_pcName.Content="Welcome $pcName"

$cpuInfo=Get-CimInstance -ClassName CIM_Processor | Select-Object *
$wpf_cpuInfo.Content=$cpuInfo.Name

Get-CimInstance -ClassName win32_VideoController | ForEach-Object {[void]$wpf_gpuInfo.Items.Add($_.VideoProcessor)}

$ramInfo = get-wmiobject -class Win32_ComputerSystem
$ramInfoGB=[math]::Ceiling($ramInfo.TotalPhysicalMemory / 1024 / 1024 / 1024)
$ramSpeed=Get-WmiObject Win32_PhysicalMemory | Select-Object *
$IsVirtual=$ramInfo.Model.Contains("Virtual")
if ($IsVirtual -like 'False'){
    Write-Output "This Machine is Physical Platform"
    $wpf_ramInfo.Content=[string]$ramInfoGB+"GB"+" "+ $ramSpeed.ConfiguredClockSpeed[0]+"MT/s"
} else{
    Write-Output "This Machine is Virtual Platform"
    $wpf_ramInfo.Content=[string]$ramInfoGB+"GB"
}

$mbInfo=Get-CimInstance -ClassName win32_baseboard | Select-Object *
$wpf_mbInfo.Content=$mbInfo.Product

# OS INFO
$osInfo=(Get-CimInstance -class Win32_OperatingSystem).Caption
$wpf_osInfo.Content=$osInfo

$verInfo=(Get-CimInstance Win32_OperatingSystem).BuildNumber
$wpf_verInfo.Content=$verInfo

$installTimeInfo=(Get-CimInstance Win32_OperatingSystem).InstallDate
$wpf_installTimeInfo.Content=$installTimeInfo

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

Get-WmiObject -Class win32_logicaldisk | ForEach-Object {[void]$wpf_diskName.Items.Add($_.DeviceId)}
function Get-DiskSize {
    $diskSelected=$wpf_diskName.SelectedItem
    $details=Get-WmiObject -Class win32_logicaldisk -Filter  "DeviceID = '$diskSelected'" | Select-Object *
    $wpf_diskMaxSize.Content=("{0}GB" -f [math]::truncate($details.Size / 1GB))
    $wpf_diskFreeSize.Content=("{0}GB" -f [math]::truncate($details.FreeSpace / 1GB))
}