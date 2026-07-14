[CmdletBinding()]
param(
    [uri]$BaseUri = "https://cpu-design.p.cs-lab.top/",
    [string]$OutputDir = "mirror",
    [ValidateRange(1, 50000)]
    [int]$MaxFiles = 5000,
    [ValidateRange(1, 600)]
    [int]$TimeoutSec = 30,
    [ValidateRange(0, 10)]
    [int]$Retries = 2
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$outputPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDir))
$stagingPath = [IO.Path]::GetFullPath((Join-Path $repoRoot ".mirror-staging"))
$repoPrefix = $repoRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar

if (-not $outputPath.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "OutputDir must be inside the repository: $repoRoot"
}
if ($outputPath -eq $stagingPath) {
    throw "OutputDir cannot be the reserved .mirror-staging directory."
}

$baseBuilder = [UriBuilder]::new($BaseUri)
$baseBuilder.Fragment = ""
$baseBuilder.Query = ""
if (-not $baseBuilder.Path.EndsWith("/")) {
    $baseBuilder.Path += "/"
}
$BaseUri = $baseBuilder.Uri
$basePath = $BaseUri.AbsolutePath

function Get-NormalizedUri {
    param([uri]$Uri, [uri]$RelativeTo)

    try {
        $resolved = [uri]::new($RelativeTo, $Uri)
    } catch {
        return $null
    }

    if ($resolved.Scheme -notin @("http", "https")) { return $null }
    if ($resolved.Scheme -ne $BaseUri.Scheme -or
        $resolved.Host -ne $BaseUri.Host -or
        $resolved.Port -ne $BaseUri.Port) { return $null }
    if (-not $resolved.AbsolutePath.StartsWith($basePath, [StringComparison]::Ordinal)) { return $null }

    $builder = [UriBuilder]::new($resolved)
    $builder.Fragment = ""
    # Static-site query strings normally only bust caches. Strip them to deduplicate files.
    $builder.Query = ""
    # MkDocs pages are directories. PowerShell 5.1 does not reliably follow HTTP 308,
    # so canonicalize extensionless page aliases before requesting them.
    if (-not $builder.Path.EndsWith("/") -and [IO.Path]::GetExtension($builder.Path) -eq "") {
        $builder.Path += "/"
    }
    return $builder.Uri
}

function Get-RelativeFilePath {
    param([uri]$Uri)

    $relative = [uri]::UnescapeDataString($Uri.AbsolutePath.Substring($basePath.Length))
    $segments = @($relative -split "/" | Where-Object { $_ -ne "" })
    foreach ($segment in $segments) {
        if ($segment -in @(".", "..") -or $segment.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) {
            throw "URL cannot be mapped to a safe local path: $Uri"
        }
    }

    if ($relative -eq "" -or $relative.EndsWith("/")) {
        $relative = $relative + "index.html"
    } elseif ([IO.Path]::GetExtension($relative) -eq "") {
        $relative = $relative.TrimEnd("/") + "/index.html"
    }

    return $relative.Replace("/", [IO.Path]::DirectorySeparatorChar)
}

function Get-LinksFromText {
    param([string]$Text, [uri]$PageUri, [string]$ContentType)

    $candidates = [Collections.Generic.List[string]]::new()
    if ($ContentType -match "text/html|application/xhtml") {
        $attributePattern = '(?is)(?:href|src|poster|data-src)\s*=\s*["'']([^"''#]+)["'']'
        foreach ($match in [regex]::Matches($Text, $attributePattern)) {
            $candidates.Add($match.Groups[1].Value.Trim())
        }
        $srcsetPattern = '(?is)(?:srcset|data-srcset)\s*=\s*["'']([^"'']+)["'']'
        foreach ($match in [regex]::Matches($Text, $srcsetPattern)) {
            foreach ($item in $match.Groups[1].Value.Split(",")) {
                $url = ($item.Trim() -split "\s+")[0]
                if ($url) { $candidates.Add($url) }
            }
        }
    }
    if ($ContentType -match "text/css|text/html|application/xhtml") {
        $cssPattern = '(?is)url\(\s*["'']?([^\)"'']+)["'']?\s*\)'
        foreach ($match in [regex]::Matches($Text, $cssPattern)) {
            $candidates.Add($match.Groups[1].Value.Trim())
        }
    }

    foreach ($candidate in $candidates) {
        if (-not $candidate -or $candidate.StartsWith("#") -or
            $candidate.StartsWith("data:") -or $candidate.StartsWith("javascript:") -or
            $candidate.StartsWith("mailto:") -or $candidate.StartsWith("tel:")) {
            continue
        }
        try {
            $candidateUri = [uri]::new($PageUri, $candidate)
            $normalized = Get-NormalizedUri -Uri $candidateUri -RelativeTo $PageUri
            if ($null -ne $normalized) { $normalized }
        } catch {
            Write-Warning "Ignoring an invalid URL: $candidate"
        }
    }
}

if (Test-Path -LiteralPath $stagingPath) {
    Remove-Item -LiteralPath $stagingPath -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingPath | Out-Null

$queue = [Collections.Generic.Queue[uri]]::new()
$queued = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$entries = [Collections.Generic.List[object]]::new()
$missing = [Collections.Generic.List[object]]::new()

function Add-ToQueue {
    param([uri]$Uri)
    $normalized = Get-NormalizedUri -Uri $Uri -RelativeTo $BaseUri
    if ($null -ne $normalized -and $queued.Add($normalized.AbsoluteUri)) {
        $queue.Enqueue($normalized)
    }
}

Add-ToQueue $BaseUri
foreach ($wellKnown in @("search/search_index.json", "sitemap.xml", "robots.txt")) {
    Add-ToQueue ([uri]::new($BaseUri, $wellKnown))
}

try {
    while ($queue.Count -gt 0) {
        if ($entries.Count -ge $MaxFiles) {
            throw "MaxFiles=$MaxFiles exceeded. Stopping to guard against a site configuration error."
        }

        $current = $queue.Dequeue()
        $relativePath = Get-RelativeFilePath $current
        $destination = Join-Path $stagingPath $relativePath
        $parent = Split-Path -Parent $destination
        New-Item -ItemType Directory -Force -Path $parent | Out-Null

        $response = $null
        $lastError = $null
        for ($attempt = 0; $attempt -le $Retries; $attempt++) {
            try {
                $response = Invoke-WebRequest -Uri $current -UseBasicParsing -TimeoutSec $TimeoutSec -OutFile $destination -PassThru
                $lastError = $null
                break
            } catch {
                $lastError = $_
                if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Force }
                if ($attempt -lt $Retries) { Start-Sleep -Seconds ([Math]::Min(1 + $attempt, 3)) }
            }
        }

        if ($null -ne $lastError) {
            $statusCode = 0
            if ($null -ne $lastError.Exception.Response) {
                $statusCode = [int]$lastError.Exception.Response.StatusCode
            }
            # Record broken site links, but keep network and authorization failures fatal.
            if ($statusCode -in @(404, 410) -or $current.AbsoluteUri -in @(
                ([uri]::new($BaseUri, "robots.txt")).AbsoluteUri,
                ([uri]::new($BaseUri, "sitemap.xml")).AbsoluteUri
            )) {
                Write-Warning "Site returned HTTP $statusCode; skipping missing file: $current"
                $missing.Add([ordered]@{
                    source = $current.AbsoluteUri
                    status = $statusCode
                })
                continue
            }
            throw "Download failed: $current`n$lastError"
        }

        $contentType = [string]$response.Headers["Content-Type"]
        $fileInfo = Get-Item -LiteralPath $destination
        $hash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
        $entries.Add([ordered]@{
            path = $relativePath.Replace([IO.Path]::DirectorySeparatorChar, "/")
            source = $current.AbsoluteUri
            bytes = $fileInfo.Length
            sha256 = $hash
            content_type = $contentType
        })
        Write-Host ("[{0}/{1}] {2}" -f $entries.Count, ($entries.Count + $queue.Count), $current.AbsoluteUri)

        if ($contentType -match "text/html|application/xhtml|text/css") {
            $text = [IO.File]::ReadAllText($destination, [Text.Encoding]::UTF8)
            foreach ($link in Get-LinksFromText -Text $text -PageUri $current -ContentType $contentType) {
                Add-ToQueue $link
            }
        }
    }

    $manifest = [ordered]@{
        schema_version = 1
        base_url = $BaseUri.AbsoluteUri
        file_count = $entries.Count
        files = @($entries | Sort-Object path)
        missing = @($missing | Sort-Object source)
    }
    $manifestPath = Join-Path $stagingPath "mirror-manifest.json"
    [IO.File]::WriteAllText(
        $manifestPath,
        (($manifest | ConvertTo-Json -Depth 6) + [Environment]::NewLine),
        [Text.UTF8Encoding]::new($false)
    )

    if (Test-Path -LiteralPath $outputPath) {
        Remove-Item -LiteralPath $outputPath -Recurse -Force
    }
    Move-Item -LiteralPath $stagingPath -Destination $outputPath
    Write-Host "Mirror complete: $($entries.Count) files saved to $outputPath"
} catch {
    if (Test-Path -LiteralPath $stagingPath) {
        Remove-Item -LiteralPath $stagingPath -Recurse -Force
    }
    throw
}
