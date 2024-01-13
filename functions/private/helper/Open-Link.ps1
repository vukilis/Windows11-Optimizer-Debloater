Function Open-Link {
    <#
    .SYNOPSIS
        Function that opens a url link
        Open-Link -Uri $navigateUriGit
    #>

    param($Uri)

    try {
        Start-Process $Uri
    }
    catch {
        [System.Windows.MessageBox]::Show("Error opening link: $_", "Error", [Windows.MessageBoxButton]::OK, [Windows.MessageBoxImage]::Error)
    }
}

$wpf_GitHubHyperlink.Add_Click({
    <#
    .SYNOPSIS
        Open GitHub page link
    #>
    $GitHubHyperlink = $psform.FindName("GitHubHyperlink")
    $navigateUriGit = Get-NavigateUri -hyperlink $GitHubHyperlink
    Open-Link -Uri $navigateUriGit
})

$wpf_WebsiteHyperlink.Add_Click({
    <#
    .SYNOPSIS
        Open Website link
    #>
    $WebsiteHyperlink = $psform.FindName("WebsiteHyperlink")
    $navigateUriSite = Get-NavigateUri -hyperlink $WebsiteHyperlink
    Open-Link -Uri $navigateUriSite
})