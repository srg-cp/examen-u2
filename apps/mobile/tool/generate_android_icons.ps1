[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$appDirectory = Split-Path -Parent $PSScriptRoot
$repoDirectory = Split-Path -Parent $appDirectory
$vectorSourcePath = Join-Path $repoDirectory 'logo/Logo EntreHuellas 512 vector inner v2-16.svg'
$resourcesDirectory = Join-Path $appDirectory 'android/app/src/main/res'
$utf8Encoding = New-Object System.Text.UTF8Encoding($false)

[xml]$vectorSource = Get-Content -LiteralPath $vectorSourcePath -Raw
$namespaces = New-Object System.Xml.XmlNamespaceManager($vectorSource.NameTable)
$namespaces.AddNamespace('svg', 'http://www.w3.org/2000/svg')
$sourcePaths = $vectorSource.SelectNodes('/svg:svg/svg:g/svg:g/svg:path', $namespaces)
$sourceGradient = $vectorSource.SelectSingleNode('/svg:svg/svg:defs/svg:linearGradient', $namespaces)
if ($vectorSource.svg.viewBox -ne '0 0 512 512' -or $sourcePaths.Count -ne 5 -or !$sourceGradient) {
    throw 'El SVG no coincide con la estructura prevista. Revisar el adaptador antes de regenerar.'
}

Push-Location -LiteralPath $appDirectory
try {
    & dart run flutter_launcher_icons
    if ($LASTEXITCODE -ne 0) { throw 'Falló la generación de iconos PNG.' }
} finally {
    Pop-Location
}

function Write-IconResource {
    param([string]$RelativePath, [string]$XmlContent)
    $outputPath = Join-Path $resourcesDirectory $RelativePath
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force
    [void]([xml]$XmlContent)
    [System.IO.File]::WriteAllText($outputPath, $XmlContent + "`n", $utf8Encoding)
}

function Get-SymbolVector {
    param([switch]$Monochrome)
    $paths = foreach ($sourcePath in $sourcePaths) {
        $pathData = [System.Security.SecurityElement]::Escape($sourcePath.GetAttribute('d'))
        $fillColor = if ($Monochrome) { '#000000' } else { $sourcePath.GetAttribute('fill') }
        "        <path android:fillColor=`"$fillColor`" android:pathData=`"$pathData`" />"
    }
    # Scale the original symbol into the adaptive icon's central safe region.
    # SVG texture/inner-shadow filters are not supported by VectorDrawable.
    @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="512" android:viewportHeight="512">
    <group android:pivotX="256" android:pivotY="256"
        android:scaleX="0.72" android:scaleY="0.72">
$($paths -join "`n")
    </group>
</vector>
"@
}

$gradientStops = foreach ($stop in $sourceGradient.SelectNodes('svg:stop', $namespaces)) {
    $offset = if ($stop.HasAttribute('offset')) { $stop.GetAttribute('offset') } else { '0' }
    "                <item android:offset=`"$offset`" android:color=`"$($stop.GetAttribute('stop-color'))`" />"
}
$backgroundXml = @"
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:aapt="http://schemas.android.com/aapt"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="512" android:viewportHeight="512">
    <path android:pathData="M0,0H512V512H0Z">
        <aapt:attr name="android:fillColor">
            <gradient android:type="linear"
                android:startX="$($sourceGradient.GetAttribute('x1'))" android:startY="$($sourceGradient.GetAttribute('y1'))"
                android:endX="$($sourceGradient.GetAttribute('x2'))" android:endY="$($sourceGradient.GetAttribute('y2'))">
$($gradientStops -join "`n")
            </gradient>
        </aapt:attr>
    </path>
</vector>
"@

Write-IconResource 'drawable/ic_launcher_foreground.xml' (Get-SymbolVector)
Write-IconResource 'drawable/ic_launcher_monochrome.xml' (Get-SymbolVector -Monochrome)
Write-IconResource 'drawable/ic_launcher_background.xml' $backgroundXml
Write-IconResource 'mipmap-anydpi-v26/ic_launcher.xml' @'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
'@
Write-IconResource 'mipmap-anydpi-v33/ic_launcher.xml' @'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
'@

Write-Output 'Iconos Android clásicos, adaptativos y monocromáticos generados.'
