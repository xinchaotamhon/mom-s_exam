$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$wranglerPath = Join-Path $root 'wrangler.jsonc'
if (-not (Test-Path -LiteralPath $wranglerPath)) { throw 'Missing wrangler.jsonc.' }

$wrangler = Get-Content -Raw -LiteralPath $wranglerPath | ConvertFrom-Json
if ($wrangler.name -ne 'mom-s-exam') { throw 'Wrangler Worker name must match the connected Cloudflare Worker.' }
if ($wrangler.assets.directory -ne './site') { throw 'Wrangler assets directory must point to ./site.' }
if ($wrangler.assets.not_found_handling -ne 'single-page-application') {
    throw 'Wrangler must provide the SPA fallback through assets.not_found_handling.'
}

$redirectsPath = Join-Path $root 'site/_redirects'
if (Test-Path -LiteralPath $redirectsPath) {
    $loopingRule = Get-Content -LiteralPath $redirectsPath | Where-Object {
        $_ -match '^\s*/\*\s+/index(?:\.html)?\s+200(?:\s|$)'
    }
    if ($loopingRule) {
        throw 'Do not duplicate the Wrangler SPA fallback with /* /index.html 200 in site/_redirects.'
    }
}

Write-Output 'Cloudflare Worker name and SPA routing configuration are deploy-safe.'
