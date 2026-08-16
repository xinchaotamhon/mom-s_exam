$ErrorActionPreference = 'Stop'

$raw = 'data/source/original.docx'
$extracted = 'data/derived/extracted-document.json'
$bank = 'data/derived/question-bank-base.json'

foreach ($path in @($raw, $extracted, $bank)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing pipeline artifact: $path" }
}

$extractedPayload = Get-Content -Raw -LiteralPath $extracted | ConvertFrom-Json
$bankPayload = Get-Content -Raw -LiteralPath $bank | ConvertFrom-Json
$rawHash = (Get-FileHash -LiteralPath $raw -Algorithm SHA256).Hash.ToLowerInvariant()

if ($rawHash -ne $extractedPayload.source.sha256) { throw 'Raw DOCX hash differs from extraction provenance' }
if ($extractedPayload.stats.paragraphs -ne 2407) { throw "Expected 2407 paragraphs, got $($extractedPayload.stats.paragraphs)" }
if ($bankPayload.stats.multipleChoice -ne 395) { throw "Expected 395 MCQ, got $($bankPayload.stats.multipleChoice)" }
if ($bankPayload.stats.oral -ne 143) { throw "Expected 143 oral questions, got $($bankPayload.stats.oral)" }
if ($bankPayload.stats.total -ne 538) { throw "Expected 538 total questions, got $($bankPayload.stats.total)" }

foreach ($question in $bankPayload.multipleChoice) {
    if ($question.options.Count -ne 4) { throw "$($question.id) does not have exactly 4 options" }
    if (($question.options | Where-Object { [string]::IsNullOrWhiteSpace($_.text) }).Count -gt 0) {
        throw "$($question.id) has an empty option"
    }
}

Write-Output 'Source pipeline preserves the DOCX and yields 395 MCQ plus 143 oral questions.'
