
function Invoke-Configs {
    <#
    .DESCRIPTION
    Simple Switch for lagacy windows
    #>
    param($Panel)

    switch ($Panel){
        "wpf_PanelControl"              {cmd /c control}
        "wpf_PanelPnF"                  {cmd /c appwiz.cpl}
        "wpf_PanelNetwork"              {cmd /c ncpa.cpl}
        "wpf_PanelPower"                {cmd /c powercfg.cpl}
        "wpf_PanelSound"                {cmd /c mmsys.cpl}
        "wpf_PanelSystem"               {cmd /c sysdm.cpl}
        "wpf_PanelUser"                 {cmd /c "control userpasswords2"}
        "wpf_PanelServices"             {cmd /c services.msc}
        "wpf_PanelWindowsFirewall"      {cmd /c firewall.cpl}
        "wpf_PanelDeviceManager"        {cmd /c devmgmt.msc}
        "wpf_PanelExplorerOption"       {cmd /c control folders}
        "wpf_PanelRegedit"              {cmd /c regedit}
        "wpf_PanelScheduler"            {cmd /c taskschd.msc}
        "wpf_PanelResourceMonitor"      {cmd /c resmon}
        "wpf_PanelSysConf"              {cmd /c msconfig}
        "wpf_PanelEvent"                {cmd /c taskschd.msc}
        "wpf_PanelSysInfo"              {cmd /c msinfo32}
        "wpf_PanelDiskManagement"       {cmd /c diskmgmt.msc}
        "wpf_PanelRegion"               {cmd /c intl.cpl}
        "wpf_PanelComputer"             {cmd /c compmgmt.msc}
        "wpf_PanelTimedate"             {cmd /c timedate.cpl}
    }
}