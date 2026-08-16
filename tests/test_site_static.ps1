$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$required = @(
    'site/index.html',
    'site/styles.css',
    'site/app.js',
    'site/data/question-bank.json',
    'site/manifest.webmanifest',
    'site/service-worker.js',
    'site/_headers',
    'site/_redirects',
    'wrangler.jsonc'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative))) { throw "Missing deployment file: $relative" }
}

$html = Get-Content -Raw -LiteralPath (Join-Path $root 'site/index.html')
foreach ($reference in @('/styles.css', '/app.js', '/manifest.webmanifest', '/icon.svg')) {
    if ($html -notmatch [regex]::Escape($reference)) { throw "index.html does not reference $reference" }
}
if ($html -match '<script(?![^>]+src=)') { throw 'Inline scripts are not allowed by the content security policy.' }

$manifest = Get-Content -Raw -LiteralPath (Join-Path $root 'site/manifest.webmanifest') | ConvertFrom-Json
if ($manifest.lang -ne 'vi' -or $manifest.start_url -ne '/') { throw 'Manifest language or start URL is invalid.' }

$bank = Get-Content -Raw -LiteralPath (Join-Path $root 'site/data/question-bank.json') | ConvertFrom-Json
if ($bank.stats.total -ne 538 -or @($bank.sources).Count -lt 10) { throw 'Compiled content or source list is incomplete.' }
if (@($bank.sources | Where-Object { $_.url -and $_.url -notmatch '^https://' }).Count -ne 0) { throw 'Every public source URL must use HTTPS.' }

$node = Get-Command node -ErrorAction SilentlyContinue
if ($null -ne $node) {
    & $node.Source --check (Join-Path $root 'site/app.js')
    if ($LASTEXITCODE -ne 0) { throw 'app.js did not pass the Node syntax check.' }
    & $node.Source --check (Join-Path $root 'site/service-worker.js')
    if ($LASTEXITCODE -ne 0) { throw 'service-worker.js did not pass the Node syntax check.' }
}

Write-Output 'Static Cloudflare package is complete and syntactically valid.'
