# Dot source all functionscripts - the manifest limits exported functions
$FunctionsPath = "$PSScriptRoot\Functions\*.ps1"
$Functions     = Resolve-Path -Path $FunctionsPath -ErrorAction Stop

ForEach ($Function in $Functions) {
    . $Function.Path
}
