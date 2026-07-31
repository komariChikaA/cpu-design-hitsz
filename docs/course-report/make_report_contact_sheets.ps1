param(
    [string]$PagesDirectory = (Join-Path $PSScriptRoot '..\..\outputs\report\final-qa'),
    [int]$PagesPerSheet = 4
)

Add-Type -AssemblyName System.Drawing
$pages = Get-ChildItem -LiteralPath $PagesDirectory -Filter 'page-*.png' |
    Sort-Object Name

for ($start = 0; $start -lt $pages.Count; $start += $PagesPerSheet) {
    $batch = @($pages[$start..([Math]::Min($start + $PagesPerSheet - 1, $pages.Count - 1))])
    $first = [System.Drawing.Image]::FromFile($batch[0].FullName)
    $tileWidth = [int]($first.Width / 2)
    $tileHeight = [int]($first.Height / 2)
    $first.Dispose()

    $canvas = New-Object System.Drawing.Bitmap ($tileWidth * 2), ($tileHeight * 2)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.Clear([System.Drawing.Color]::FromArgb(220, 220, 220))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    for ($i = 0; $i -lt $batch.Count; $i++) {
        $image = [System.Drawing.Image]::FromFile($batch[$i].FullName)
        $x = ($i % 2) * $tileWidth
        $y = [Math]::Floor($i / 2) * $tileHeight
        $graphics.DrawImage($image, $x, $y, $tileWidth, $tileHeight)
        $image.Dispose()
    }

    $number = [int]($start / $PagesPerSheet) + 1
    $output = Join-Path $PagesDirectory ("contact-{0:d2}.png" -f $number)
    $canvas.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $canvas.Dispose()
    Write-Output $output
}
