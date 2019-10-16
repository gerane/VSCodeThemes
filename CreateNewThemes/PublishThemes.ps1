$dirThemes = (gci "C:\github\VSCodeThemes" -Directory -Filter 'gerane*').FullName


foreach ($theme in $dirThemes)
{
    pushd $theme
    vsce package
    vsce publish
    popd
}