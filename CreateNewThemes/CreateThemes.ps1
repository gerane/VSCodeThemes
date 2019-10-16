function New-Theme
{
    param
    (
        $ThemeName,
        $ThemeUrl
    )
    begin
    {
        $ThemeFolder = 'gerane.Theme-' + $ThemeName
        $BaseThemeDir = "C:\github\VSCode-ZenburnTheme\gerane.Theme-Zenburn"
        $VSCodeThemesDir = "C:\github\VSCodeThemes"
        $NewThemeDir = $VSCodeThemesDir + '\' + $ThemeFolder
    }
    process
    {
        New-Item $NewThemeDir -ItemType Directory
        Copy-Item -Path "C:\github\VSCode-ZenburnThemetemp\gerane.Theme-Zenburn\*" -Destination $NewThemeDir -Recurse
        Remove-Item -Path "$NewThemeDir\themes\*" -Recurse -Include '*.tmTheme'
    }
    end {}
}
#New-Theme -ThemeName TestTheme -ThemeUrl $ThemeUrl

function Set-ThemeJson
{
    param
    (
        $ThemeName,
        $tmtheme
    )
    begin
    {
        $ThemeFolder = 'gerane.Theme-' + $ThemeName
        $BaseThemeDir = "C:\github\VSCode-ZenburnThemeTemp\gerane.Theme-Zenburn"
        $VSCodeThemesDir = "C:\github\VSCodeThemes"
        $NewThemeDir = $VSCodeThemesDir + '\' + $ThemeFolder
    }
    process
    {
        $JsonThemeName = 'Theme-' + $ThemeName

        $JsonFile = Get-Content "$NewThemeDir\package.json"
        $JsonFile1 = $jsonfile.replace('Changeme1',"Theme-$ThemeName")
        $JsonFile2 = $JsonFile1.replace('Changeme2',"$($ThemeName) Theme")
        $JsonFile3 = $JsonFile2.Replace('Changeme3',"$ThemeName Theme ported from the $ThemeName TextMate Theme")
        $JsonFile4 = $JsonFile3.Replace('Changeme4',$ThemeName)
        $JsonFile5 = $JsonFile4.Replace('Changeme5',$ThemeName)
        $JsonFile6 = $JsonFile5.Replace('Changeme6',$tmtheme)
        $JsonFile6 | Out-File -FilePath "$NewThemeDir\package.json" -Encoding ascii

    }
    end {}
}
#Set-ThemeJson -ThemeName $ThemeName

function Set-ThemeReadme
{
    param
    (
        $ThemeName,
        $ThemeUrl
    )
    begin
    {
        $ThemeFolder = 'gerane.Theme-' + $ThemeName
        $BaseThemeDir = "C:\github\VSCode-ZenburnTheme\gerane.Theme-Zenburn"
        $VSCodeThemesDir = "C:\github\VSCodeThemes"
        $NewThemeDir = $VSCodeThemesDir + '\' + $ThemeFolder
    }
    process
    {
        $Readme = @()
        $Readme += "# $ThemeName"
        $Readme += ""
        $Readme += "A theme based on the [$ThemeName TextMate Theme]($ThemeUrl)."
        $Readme | Out-File -FilePath "$NewThemeDir\README.md" -Force -Encoding ascii
    }
    end {}
}

function Get-ThemeFile
{
    param
    (
        $DownloadUrl,
        $TmTheme
    )
    begin
    {
        $ThemeFolder = 'gerane.Theme-' + $ThemeName
        $BaseThemeDir = "C:\github\VSCode-ZenburnThemeTemp\gerane.Theme-Zenburn"
        $VSCodeThemesDir = "C:\github\VSCodeThemes"
        $NewThemeDir = $VSCodeThemesDir + '\' + $ThemeFolder
    }
    process
    {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile "$NewThemeDir\themes\$tmtheme"
    }
    End {}
}


$xml = 'C:\Users\Admin\Downloads\sitemap.xml'
[xml]$content = Get-Content $xml
$urllist = $content.urlset.url

foreach ($url in $urllist)
{
    $url = $url.loc
    if ($url -like 'http://colorsublime.com/theme/*')
    {
        $WebContent = Invoke-WebRequest -Uri $url

        $DownloadUrl = ($WebContent.links | where { $_.innertext -like '*Download*' }).href
        $ThemeUrl = $url
        $ThemeName = $Url.split('/')[-1]
        $TmTheme = ((((Invoke-WebRequest -Uri (($WebContent.links | where { $_.innertext -like '*Download*' }).href)).headers)."content-disposition").split('=')[1]).replace("`"","")


        New-Theme -ThemeName $ThemeName -ThemeUrl $ThemeUrl
        Get-ThemeFile -DownloadUrl $DownloadUrl -TmTheme $TmTheme
        Set-ThemeJson -ThemeName $ThemeName -tmtheme $TmTheme
        Set-ThemeReadme -ThemeName $ThemeName -ThemeUrl $ThemeUrl
    }
}

