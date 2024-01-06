Get-Service -ErrorAction SilentlyContinue | ForEach-Object {[void]$wpf_ddlServices.Items.Add($_.Name)}
function Get-Services {
    <#

    .SYNOPSIS
        Function to get all services and their information 
    #>

    $ServiceName = $wpf_ddlServices.SelectedItem
    # Use Get-WmiObject to retrieve service information
    $serviceInfo = Get-WmiObject -Class Win32_Service -Filter "Name = '$ServiceName'"
    # Use Get-Service to retrieve service information
    $serviceDetails = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue | Select-Object *
    # Use Display service information from Get-Service if available, otherwise fallback to WMI
    $wpf_lblName.Content = if ($serviceDetails.DisplayName) { $serviceDetails.DisplayName } else { $serviceInfo.Name }
    $wpf_lblStatus.Content = if ($serviceDetails.Status) { $serviceDetails.Status } else { $serviceInfo.State }
    $wpf_lblStartupType.Content = if ($serviceDetails.StartupType) { $serviceDetails.StartupType } else { $serviceInfo.StartMode }
    $wpf_lblServicesDesc.Text = if ($serviceDetails.Description) { $serviceDetails.Description } else { $serviceInfo.Description }


    ### status color
    $wpf_lblStatus.Foreground = switch ($wpf_lblStatus.Content) {
        'Stopped' {'red'} 
        'Paused' {'yellow'} 
        default {'green'}
    }
    ### type color
    $wpf_lblStartupType.Foreground = switch ($wpf_lblStartupType.Content) {
        'Manual' {'yellow'} 
        'Automatic' {'blue'} 
        default {'red'}
    }
}