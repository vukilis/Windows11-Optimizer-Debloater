function Invoke-FeatureInstall {
    <#
    .DESCRIPTION
    GUI Function to install Windows Features
    #>
    If ( $wpf_FeaturesDotnet.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx4-AdvSrvs" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart
    }
    If ( $wpf_FeaturesHyperv.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "HypervisorPlatform" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Tools-All" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-PowerShell" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Hypervisor" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Services" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-Clients" -All -NoRestart
        cmd /c bcdedit /set hypervisorschedulertype classic
        Write-Host "HyperV is now installed and configured. Please Reboot before using."
    }
    If ( $wpf_FeaturesLegacymedia.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "MediaPlayback" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "DirectPlay" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "LegacyComponents" -All -NoRestart
    }
    If ( $wpf_FeatureWsl.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
        Write-Host "WSL is now installed and configured. Please Reboot before using."
    }
    If ( $wpf_FeatureNfs.IsChecked -eq $true ) {
        Enable-WindowsOptionalFeature -Online -FeatureName "ServicesForNFS-ClientOnly" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "ClientForNFS-Infrastructure" -All -NoRestart
        Enable-WindowsOptionalFeature -Online -FeatureName "NFS-Administration" -All -NoRestart
        nfsadmin client stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousUID" -Type DWord -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousGID" -Type DWord -Value 0
        nfsadmin client start
        nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i
        Write-Host "NFS is now setup for user based NFS mounts"
    }

    Write-Host "================================="
    Write-Host "---  Features are Installed   ---"
    Write-Host "================================="

    Invoke-MessageBox -msg "feature"
}