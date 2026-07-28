param(
    [string]$InputPng = (Join-Path $PSScriptRoot 'singlecycle-overview.png'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'report')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$source = [System.Drawing.Bitmap]::FromFile((Resolve-Path -LiteralPath $InputPng))
try {
    [System.IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
    Get-ChildItem -LiteralPath $OutputDirectory -Filter 'singlecycle-part-*.png' -File -ErrorAction SilentlyContinue |
        Remove-Item -Force

    # Keep every crop tight around one or two adjacent modules.  At A4
    # landscape size this raises the 15 px source port labels to roughly
    # 12--16 pt, while the full overview remains available for global wiring.
    # X/Y/Width/Height are fractions of the generated overview PNG.
    # render.mjs leaves a 64 px horizontal and 128 px vertical page gutter
    # around the scaled SVG content; include that gutter in the crop origin.
    $contentOffsetX = 64
    $contentOffsetY = 128
    $panels = @(
        @{ Name = 'singlecycle-part-1-npc-pc.png';          X = 0.009; Y = 0.495; Width = 0.136; Height = 0.248 },
        @{ Name = 'singlecycle-part-2-pc-rom.png';          X = 0.084; Y = 0.487; Width = 0.144; Height = 0.153 },
        @{ Name = 'singlecycle-part-3-decode.png';          X = 0.223; Y = 0.429; Width = 0.079; Height = 0.281 },
        @{ Name = 'singlecycle-part-4-control-sext.png';    X = 0.298; Y = 0.128; Width = 0.147; Height = 0.314 },
        @{ Name = 'singlecycle-part-5-writeback-rf.png';    X = 0.443; Y = 0.347; Width = 0.139; Height = 0.256 },
        @{ Name = 'singlecycle-part-6-ex.png';              X = 0.586; Y = 0.033; Width = 0.140; Height = 0.322 },
        @{ Name = 'singlecycle-part-7-mreq-dram.png';       X = 0.726; Y = 0.371; Width = 0.171; Height = 0.223 },
        @{ Name = 'singlecycle-part-8-dram-mext.png';       X = 0.810; Y = 0.371; Width = 0.163; Height = 0.235 }
    )

    foreach ($panel in $panels) {
        $x = $contentOffsetX + [int][Math]::Round($source.Width * $panel.X)
        $y = $contentOffsetY + [int][Math]::Round($source.Height * $panel.Y)
        $width = [int][Math]::Round($source.Width * $panel.Width)
        $height = [int][Math]::Round($source.Height * $panel.Height)
        if ($x + $width -gt $source.Width) {
            $width = $source.Width - $x
        }
        if ($y + $height -gt $source.Height) {
            $height = $source.Height - $y
        }

        $crop = [System.Drawing.Rectangle]::new($x, $y, $width, $height)
        $outputWidth = 3508
        $outputHeight = [int][Math]::Round($outputWidth * $height / $width)
        $output = [System.Drawing.Bitmap]::new(
            $outputWidth,
            $outputHeight,
            [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
        )
        try {
            $output.SetResolution(300, 300)
            $graphics = [System.Drawing.Graphics]::FromImage($output)
            try {
                $graphics.Clear([System.Drawing.Color]::White)
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $destination = [System.Drawing.Rectangle]::new(0, 0, $output.Width, $output.Height)
                $graphics.DrawImage($source, $destination, $crop, [System.Drawing.GraphicsUnit]::Pixel)
            } finally {
                $graphics.Dispose()
            }

            $path = Join-Path $OutputDirectory $panel.Name
            $output.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
            Write-Output ("{0}: crop=({1},{2},{3},{4}), output={5}x{6}" -f
                $path, $crop.X, $crop.Y, $crop.Width, $crop.Height, $output.Width, $output.Height)
        } finally {
            $output.Dispose()
        }
    }
} finally {
    $source.Dispose()
}
