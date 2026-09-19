$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $root 'tools/compile_content.ps1') | Out-Null

$bank = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'site/data/question-bank.json') | ConvertFrom-Json
$mcqPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'data/curated/mcq-explanations.json') | ConvertFrom-Json
$oralPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'data/curated/oral-school-links.json') | ConvertFrom-Json
$scenarioPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'data/curated/final-scenario-school-links.json') | ConvertFrom-Json

function Get-WordCount([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
    return @($Text.Trim() -split '\s+').Count
}

function Assert-UniqueCoverage($ExpectedIds, $Items, [string]$Label) {
    $actualIds = @($Items | ForEach-Object { [string]$_.questionId })
    if (@($actualIds | Sort-Object -Unique).Count -ne $actualIds.Count) { throw "$Label contains duplicate IDs." }
    $difference = @(Compare-Object ($ExpectedIds | Sort-Object) ($actualIds | Sort-Object))
    if ($difference.Count -ne 0) { throw "$Label does not cover the exact expected question IDs." }
}

function Normalize-Text([string]$Value) {
    return ([regex]::Replace($Value.ToLowerInvariant().Replace([char]0xA0, ' ').Trim(), '\s+', ' ')).TrimEnd('.', ' ')
}

Assert-UniqueCoverage @($bank.multipleChoice.id) @($mcqPayload.items) 'MCQ explanations'
Assert-UniqueCoverage @($bank.oral.id) @($oralPayload.items) 'Oral school links'
Assert-UniqueCoverage @($bank.finalRound.scenarios.id) @($scenarioPayload.items) 'Final scenario school links'

if (@($mcqPayload.items).Count -ne 395) { throw 'Expected 395 concise MCQ explanations.' }
if (@($oralPayload.items).Count -ne 143) { throw 'Expected 143 oral school applications.' }
if (@($scenarioPayload.items).Count -ne 20) { throw 'Expected 20 final-scenario school applications.' }

foreach ($question in @($bank.multipleChoice)) {
    $words = Get-WordCount $question.explanation
    if ($words -lt 20 -or $words -gt 70) { throw "$($question.id) explanation must contain 20-70 words; found $words." }
    if ($question.explanation -match '…') { throw "$($question.id) explanation is truncated with an ellipsis." }
    if ($question.explanation -notmatch "^(Chọn|Đáp án|Phương án)\s+$($question.correctOption)\b") { throw "$($question.id) explanation must state its actual selected option directly." }
    $correctText = ($question.options | Where-Object id -eq $question.correctOption | Select-Object -First 1).text
    $oldTemplate = "Đáp án $($question.correctOption). $correctText"
    if ((Normalize-Text $question.explanation) -eq (Normalize-Text $oldTemplate)) { throw "$($question.id) only repeats the correct option." }
    if ($correctText -match '(?i)cả\s*3|cả ba|tất cả các hình thức' -and $question.explanation -match 'Cốt lõi là tuân thủ|Lựa chọn này đủ điều kiện') {
        throw "$($question.id) uses a generic explanation for a combined-answer option."
    }
    if ($question.explanationKind -ne 'concise-oral-rationale') { throw "$($question.id) lost its concise explanation marker." }
}

$locality = [string]$bank.applicationContext.localityLabel
foreach ($fragment in @('Trường Mầm non Sơn Thịnh', 'xã Văn Chấn', 'tỉnh Lào Cai', 'Yên Bái')) {
    if ($locality -notmatch [regex]::Escape($fragment)) { throw "Application locality is missing: $fragment" }
}

foreach ($question in @($bank.oral)) {
    $words = Get-WordCount $question.schoolApplication
    if ($words -lt 35 -or $words -gt 85) { throw "$($question.id) school application must contain 35-85 words; found $words." }
    if ($question.schoolApplication -notmatch 'Trường Mầm non Sơn Thịnh') { throw "$($question.id) does not name the workplace." }
    if ($question.schoolApplication -match '(?i)đã xảy ra tại trường|trường đã vi phạm') { throw "$($question.id) presents an invented incident as fact." }
    if (@($question.schoolApplicationSourceIds).Count -lt 2) { throw "$($question.id) lacks locality/context sources." }
}

foreach ($scenario in @($bank.finalRound.scenarios)) {
    $words = Get-WordCount $scenario.schoolApplication
    if ($words -lt 35 -or $words -gt 90) { throw "$($scenario.id) school application must contain 35-90 words; found $words." }
    if ($scenario.schoolApplication -notmatch 'Trường Mầm non Sơn Thịnh') { throw "$($scenario.id) does not name the workplace." }
    if ($scenario.schoolApplication -match '(?i)đã xảy ra tại trường|trường đã vi phạm') { throw "$($scenario.id) presents an invented incident as fact." }
}

foreach ($finalQuestion in @($bank.finalRound.multipleChoice)) {
    $normalizedPrompt = Normalize-Text $finalQuestion.prompt
    $matches = @($bank.multipleChoice | Where-Object { (Normalize-Text $_.prompt) -eq $normalizedPrompt })
    if ($matches.Count -ne 1 -or $finalQuestion.explanation -ne $matches[0].explanation) {
        throw "$($finalQuestion.id) must reuse the reviewed concise explanation from the 395-question bank."
    }
}

$sourceIds = @($bank.sources.id)
foreach ($sourceId in @('son-thinh-current-locality', 'son-thinh-school-context', 'son-thinh-digital-context')) {
    if ($sourceId -notin $sourceIds) { throw "Missing school-context source: $sourceId" }
}

$html = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'site/index.html')
$app = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'site/app.js')
foreach ($uiMarker in @('schoolLinkButton', 'schoolLinkPanel', 'Giải thích ngắn')) {
    if ($html -notmatch [regex]::Escape($uiMarker)) { throw "Missing delivery-support UI marker: $uiMarker" }
}
foreach ($behaviorMarker in @('toggleSchoolLink', 'schoolApplication', 'schoolApplicationSourceIds')) {
    if ($app -notmatch [regex]::Escape($behaviorMarker)) { throw "Missing delivery-support behavior: $behaviorMarker" }
}

Write-Output 'Exam delivery support is complete: 395 concise MCQ explanations, 143 oral and 20 final-scenario school applications.'
