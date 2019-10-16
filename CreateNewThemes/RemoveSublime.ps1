[CmdletBinding()]
param()

$Themes = Get-ChildItem $PSScriptRoot\..\*readme.md -Recurse

foreach ($Theme in $Themes)
{
    (Get-Content $Theme.FullName | Where-Object {$_ -notmatch 'A theme based on the'}) | Out-File $Theme.FullName

    $ThemeDir = $Theme.FullName | Split-Path -Parent
    $Json = Join-Path $ThemeDir -ChildPath package.json

    ## Update Package.json
    $JsonObj = Get-Content $Json | ConvertFrom-Json
    $Version = [Version]$JsonObj.version
    $NewVersion = "$($Version.Major).$($Version.Minor).$($Version.Build + 1)"
    $JsonObj.Version = $NewVersion
    $JsonObj | ConvertTo-Json | Out-File -FilePath $Json -Encoding ascii
}