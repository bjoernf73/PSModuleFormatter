Function Invoke-ModuleFormatter {
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage="The Settings psd1-file to process")]
        [ArgumentCompleter({
            param ()
            $mbase = (Get-Module -Name 'PSScriptAnalyzer' -ListAvailable | Where-Object { $_.ModuleBase -match "Program Files" }).modulebase; 
            (Get-ChildItem -Path "$($mbase)\Settings\*" -Include *.psd1 | 
            Select-Object -ExpandProperty Name | 
            ForEach-Object {$_})
        })]
        [String]$Settings,

        [Parameter(Mandatory,HelpMessage="The PowerShell filetypes in the module to process")]
        [ValidateSet('*.ps1','*.psm1','*.psd1')]
        [String[]]$FileTypes,

        [Parameter(Mandatory,HelpMessage="The path under which I will search for files to autoformat")]
        [System.IO.DirectoryInfo]$Path, 

        [Parameter(HelpMessage="Searches recursively under the `$Path")]
        [Switch]$Recurse
    )
    Try {
        $PSScriptAnalyzerSettingsBase = (Get-Module -Name 'PSScriptAnalyzer' -ListAvailable | Where-Object { $_.ModuleBase -match "Program Files" }).modulebase + '\Settings\*'
        Write-Verbose "Settings Base: $($PSScriptAnalyzerSettingsBase)"
        [System.IO.FileInfo]$SettingsFile = Get-ChildItem -Path $PSScriptAnalyzerSettingsBase | Where-Object {$_.Name -eq $Settings}
        Write-Verbose "Settingsfile: $($SettingsFile.FullName)"
        If ($null -eq $SettingsFile) {
            Throw "Unable to find SettingsFile"
        }

        $GetChildItemsParams = @{
            Path    = "$Path\*"
            Include = $FileTypes
            Recurse = $Recurse
            EA      = 'Stop'
        }
        $Files = Get-ChildItem @GetChildItemsParams
    
        Foreach ($File in $Files) {
            $Content = $File | Get-Content -Raw -Encoding utf8 -ErrorAction 'Stop'
            $FormattedContent = Invoke-Formatter -ScriptDefinition $Content -Settings "$($SettingsFile.FullName)" -ErrorAction 'Stop'
            $FormattedContent | Out-File -FilePath "$($File.FullName)" -Encoding utf8 -Force -ErrorAction Stop
        }
    }
    Catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}