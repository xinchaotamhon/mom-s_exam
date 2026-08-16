$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$registry = Get-Content -Raw -LiteralPath (Join-Path $root 'gates/gates.json') | ConvertFrom-Json
$failures = @()

foreach ($gate in @($registry.gates | Where-Object { $_.enabled -and $_.required })) {
    Write-Output "RUN $($gate.id)"
    $workingDirectory = [IO.Path]::GetFullPath((Join-Path $root $gate.cwd))
    Push-Location $workingDirectory
    try {
        $parts = @($gate.command)
        $executable = $parts[0]
        $arguments = if ($parts.Count -gt 1) { @($parts[1..($parts.Count - 1)]) } else { @() }
        & $executable @arguments
        if ($LASTEXITCODE -ne [int]$gate.expected_exit_code) {
            $failures += "$($gate.id): exit $LASTEXITCODE"
        }
    }
    catch {
        $failures += "$($gate.id): $($_.Exception.Message)"
    }
    finally {
        Pop-Location
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "All $(@($registry.gates | Where-Object { $_.enabled -and $_.required }).Count) required gates passed."
