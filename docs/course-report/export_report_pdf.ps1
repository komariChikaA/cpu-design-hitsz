param(
    [string]$InputDocx = (Join-Path $PSScriptRoot 'report-final.docx'),
    [string]$OutputPdf = (Join-Path $PSScriptRoot 'report-final.pdf')
)

$resolvedInput = (Resolve-Path -LiteralPath $InputDocx -ErrorAction Stop).Path
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPdf)
$outputDirectory = [System.IO.Path]::GetDirectoryName($resolvedOutput)
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$word = $null
$document = $null
$finalPdf = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $document = $word.Documents.Open($resolvedInput, $false, $true)
    # 17 = wdExportFormatPDF; 0 = optimized for printing.
    $document.ExportAsFixedFormat($resolvedOutput, 17, $false, 0)
    $nameFile = Join-Path $PSScriptRoot 'report-final-name.txt'
    if (Test-Path -LiteralPath $nameFile) {
        $finalBaseName = (Get-Content -LiteralPath $nameFile -Raw -Encoding UTF8).Trim()
        if ($finalBaseName) {
            $finalPdf = Join-Path $PSScriptRoot ($finalBaseName + '.pdf')
        }
    }
}
finally {
    if ($null -ne $document) {
        $document.Close($false)
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($document) | Out-Null
    }
    if ($null -ne $word) {
        $word.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

if ($finalPdf) {
    Copy-Item -LiteralPath $resolvedOutput -Destination $finalPdf -Force
    Write-Output $finalPdf
}
Write-Output $resolvedOutput
