[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Port,
    [ValidateRange(1200, 3000000)]
    [int]$BaudRate = 115200,
    [string]$LogPath
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($LogPath)) {
    $name = 'coremark_uart_{0}.log' -f (Get-Date -Format 'yyyyMMdd_HHmmss')
    $LogPath = Join-Path $PSScriptRoot $name
}

$serial = [IO.Ports.SerialPort]::new(
    $Port,
    $BaudRate,
    [IO.Ports.Parity]::None,
    8,
    [IO.Ports.StopBits]::One
)
$serial.Handshake = [IO.Ports.Handshake]::None
$serial.DtrEnable = $false
$serial.RtsEnable = $false
$serial.ReadTimeout = 200
$serial.WriteTimeout = 200

$utf8NoBom = [Text.UTF8Encoding]::new($false)
$writer = [IO.StreamWriter]::new($LogPath, $false, $utf8NoBom)
$writer.AutoFlush = $true

try {
    $serial.Open()
    Write-Host "Listening on $Port at $BaudRate baud (8N1, no flow control)."
    Write-Host "Log: $LogPath"
    Write-Host 'Press and release S6 RST. Press Ctrl+C after FINISH.'

    while ($true) {
        $text = $serial.ReadExisting()
        if ($text.Length -gt 0) {
            [Console]::Write($text)
            $writer.Write($text)
        }
        Start-Sleep -Milliseconds 20
    }
}
finally {
    if ($serial.IsOpen) {
        $serial.Close()
    }
    $writer.Dispose()
    $serial.Dispose()
}
