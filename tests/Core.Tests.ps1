#requires -Version 7.0
Set-StrictMode -Version Latest

Describe "Config Validation" {
    It "validates tweaks.json has no duplicate keys" {
        $json = Get-Content "config\tweaks.json" -Raw | ConvertFrom-Json
        $json.PSObject.Properties.Name | Should -Not -Contain $null
    }

    It "validates all tweaks have required fields" {
        $json = Get-Content "config\tweaks.json" -Raw | ConvertFrom-Json
        foreach ($prop in $json.PSObject.Properties) {
            $prop.Value.Type | Should -Not -Be $null
            $prop.Value.Content | Should -Not -Be $null
        }
    }

    It "validates preset.json is valid" {
        $json = Get-Content "config\preset.json" -Raw | ConvertFrom-Json
        $null | Should -Be $null
    }

    It "validates feature.json is valid" {
        $json = Get-Content "config\feature.json" -Raw | ConvertFrom-Json
        $null | Should -Be $null
    }

    It "validates configuration.json is valid" {
        $json = Get-Content "config\configuration.json" -Raw | ConvertFrom-Json
        $null | Should -Be $null
    }

    It "validates applications.json is valid" {
        $json = Get-Content "config\applications.json" -Raw | ConvertFrom-Json
        $json.Count | Should -BeGreaterThan 0
    }

    It "validates msAppxDebloat.json is valid" {
        $json = Get-Content "config\msAppxDebloat.json" -Raw | ConvertFrom-Json
        $json.Count | Should -BeGreaterThan 0
    }
}
