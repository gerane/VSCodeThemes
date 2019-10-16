[CmdletBinding()]
param()
DynamicParam
{
    # Set the dynamic parameters' name
    $ParameterName = 'Name'

    # Create the dictionary
    $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

    # Create the collection of attributes
    $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

    # Create and set the parameters' attributes
    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Mandatory = $true

    # Add the attributes to the attributes collection
    $AttributeCollection.Add($ParameterAttribute)

    # Generate and set the ValidateSet
    $arrSet = Get-ChildItem -Path "$PSScriptRoot\gerane.*" -Directory | Select-Object -ExpandProperty Name | ForEach-Object { $_ -replace "gerane.Theme-","" }
    $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

    # Add the ValidateSet to the attributes collection
    $AttributeCollection.Add($ValidateSetAttribute)

    # Create and return the dynamic parameter
    $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
    $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
    return $RuntimeParameterDictionary
}

begin
{
    # Bind the parameter to a friendly variable
    $Name = $PsBoundParameters[$ParameterName]
    $NameDir = Get-ChildItem -Path "$PSScriptRoot\gerane.*" -Directory | Where-Object { $_.Name -eq "gerane.Theme-$Name" }
    $NameDir | Export-Clixml -Path 'C:\Theme.xml'
    Import-Module KaceProjects
}

process
{
    $ThemeDir = $NameDir.FullName

    $ThemeName = $NameDir.Name

    $Json = Join-Path $ThemeDir -ChildPath package.json

    Remove-Item -Path "$ThemeDir\icon.svg" -Force -ErrorAction SilentlyContinue

    ## Update Package.json
    $JsonFile = Get-Content $Json
    $Version = ($JsonFile | select-string '"version": ".*,').matches.Value[-3]
    $VersionOld = ($JsonFile | select-string '"version": ".*,').matches.Value
    $NewVersion = [convert]::ToInt32($Version, 8) + 1

    $JsonFile1 = $jsonfile.replace('icon.svg','icon.png')
    $JsonFile2 = $JsonFile1.replace($VersionOld,"`"version`": `"0.0.$NewVersion`"`,")
    $JsonFile2 | Out-File -FilePath $Json -Encoding ascii

    $FixedName = $Name -replace "_",""

    ## Update Readme
    $ReadmeNew = @"


## Screenshot
![](https://raw.githubusercontent.com/gerane/VSCodeThemes/master/gerane.Theme-$Name/screenshot.png).


## More Information
* [Visual Studio Marketplace](https://marketplace.visualstudio.com/items/gerane.Theme-$FixedName).
* [GitHub repository](https://github.com/gerane/VSCodeThemes).
"@

    $Readmefile = Join-Path $NameDir.FullName -ChildPath Readme.md
    Add-Content -Path $Readmefile -Value $ReadmeNew


    ## Take Cropped Screenshot
    Function Get-Screenshot
    {
        [CmdletBinding()]
        param
        (
            [Drawing.Rectangle]$bounds,
            $path
        )

        & code-insiders
        Start-Sleep -Seconds 2

        [Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
        $graphics = [Drawing.Graphics]::FromImage($bmp)
        $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
        $bmp.Save($path)
        $graphics.Dispose()
        $bmp.Dispose()
    }

    ## Open VSCode to Script File
    & code-insiders
    Start-Sleep -Seconds 2

    ## Screenshot Code
    $Path = "$ThemeDir\screenshot.png"
    $bounds = [Drawing.Rectangle]::FromLTRB(365, 79, 1183, 542)
    Get-Screenshot -Bounds $bounds -Path $Path

    ## Screenshot Icon
    $Path = "$ThemeDir\icon.png"
    $bounds = [Drawing.Rectangle]::FromLTRB(406, 90, 534, 218)
    Get-Screenshot -Bounds $bounds -Path $Path

    # Copy Items to Repo
    $Repo = Get-GithubRepoDir -Name VSCodeThemes
    $RepoTheme = Join-Path -Path $Repo -ChildPath $ThemeName

    Copy-Item -Path "$ThemeDir\*" -Destination $RepoTheme -Recurse -Force
    Remove-Item -Path "$RepoTheme\icon.svg" -Force -ErrorAction SilentlyContinue

    $Message = "Updated $($ThemeName -replace 'gerane.','')"

    Push-Location -Path $RepoTheme

    git add .\
    git commit -m $Message
    git push

    vsce publish

    Pop-Location
    Start-Sleep -Seconds 2

    Start-Process "C:\Program Files\Internet Explorer\iexplore.exe" -ArgumentList "https://marketplace.visualstudio.com/items/gerane.Theme-$FixedName" -WindowStyle Maximized

    #& mspaint.exe "$RepoTheme\icon.png"
    #& mspaint.exe "$RepoTheme\screenshot.png"
    #& atom "$RepoTheme\package.json"
    #& atom "$RepoTheme\readme.md"
    #& explorer.exe "$Repo\$ThemeName"
}

end
{
}