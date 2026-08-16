$ErrorActionPreference = 'Stop'

$required = @(
    'START_HERE.md',
    '00-Governance/PROJECT_PRINCIPLES.md',
    '40-State/CURRENT_STATE.md',
    '50-Evidence/EVIDENCE_INDEX.md',
    'gates/gates.json',
    'data/source/PROVENANCE.md'
)

foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing required project file: $path"
    }
}

$registry = Get-Content -Raw -LiteralPath 'gates/gates.json' | ConvertFrom-Json
if ($registry.schema_version -ne 1) { throw 'Gate registry schema version must be 1' }
if ($registry.gates.Count -lt 1) { throw 'At least one gate is required' }

Write-Output 'Foundation files and gate registry are valid.'
