Get-Service -ErrorAction SilentlyContinue | ForEach-Object {[void]$wpf_ddlServices.Items.Add($_.Name)}
function Get-Services {
    <#

    .SYNOPSIS
        Function to get all services and their information 
    #>

    $ServiceName=$wpf_ddlServices.SelectedItem
    $details=Get-Service -Name $ServiceName -ErrorAction SilentlyContinue | Select-Object *
    $wpf_lblName.Content=$details.DisplayName
    $wpf_lblStatus.Content=$details.Status
    $wpf_lblStartupType.Content=$details.StartupType

    ### display info about service
    $wpf_lblServicesDesc.Text=$details.Description

    ### status color
    if ($wpf_lblStatus.Content -eq 'Running') {
        $wpf_lblStatus.Foreground='green'
    }else{
        $wpf_lblStatus.Foreground='red'
    }

    ### type color
    if ($wpf_lblStartupType.Content -eq 'Running') {
        $wpf_lblStartupType.Foreground='green'
    }elseif ($wpf_lblStartupType.Content -eq 'Manual'){
        $wpf_lblStartupType.Foreground='yellow'
    }elseif($wpf_lblStartupType.Content -eq 'Automatic'){
        $wpf_lblStartupType.Foreground='blue'
    }else{
        $wpf_lblStartupType.Foreground='red'
    }
}