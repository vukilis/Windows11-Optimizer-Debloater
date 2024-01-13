function Get-NavigateUri {
    <#
    .SYNOPSIS
        Function that gets url links from xaml
        Get-NavigateUri -hyperlink $GitHubHyperlink 
    #>

    param (
        [System.Windows.Documents.Hyperlink]$hyperlink
    )

    if ($hyperlink -ne $null) {
        return $hyperlink.NavigateUri.AbsoluteUri
    }

    return $null
}