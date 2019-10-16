[CmdletBinding()]
param()

$Themes = Get-ChildItem ..\*readme.md -Recurse

foreach ($Theme in $Themes)
{
    (Get-Content $Theme.FullName | Where-Object {$_ -notmatch 'A theme based on the'}) | Out-File $Theme.FullName
}