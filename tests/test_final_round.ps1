$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $root 'tools/compile_content.ps1') | Out-Null
$derived = Get-Content -Raw -LiteralPath (Join-Path $root 'data/derived/final-round.json') | ConvertFrom-Json
$bank = Get-Content -Raw -LiteralPath (Join-Path $root 'site/data/question-bank.json') | ConvertFrom-Json
$mcqSource = Join-Path $root 'data/source/final-30-trac-nghiem.docx'
$scenarioSource = Join-Path $root 'data/source/final-20-tinh-huong.docx'
$correctionsPath = Join-Path $root 'data/curated/final-round-corrections.json'
if ((Get-FileHash -LiteralPath $mcqSource -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'b2578ede8aefaee4f849a851f577b1dd07b508fb7c3d9f4c18bfbf6f991b9fc8') { throw 'Final MCQ source hash changed.' }
if ((Get-FileHash -LiteralPath $scenarioSource -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'ab84877e02f300fd79cae48e2e010153825330f21c390338f0e9c369fc4426ba') { throw 'Final scenario source hash changed.' }
if ($derived.provenance.sources.'final-mcq-source'.sha256 -ne 'b2578ede8aefaee4f849a851f577b1dd07b508fb7c3d9f4c18bfbf6f991b9fc8') { throw 'Derived MCQ provenance hash mismatch.' }
if ($derived.provenance.sources.'final-scenario-source'.sha256 -ne 'ab84877e02f300fd79cae48e2e010153825330f21c390338f0e9c369fc4426ba') { throw 'Derived scenario provenance hash mismatch.' }
if ((Get-FileHash -LiteralPath $correctionsPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne $derived.provenance.correctionsSha256) { throw 'Derived final-round data is stale relative to final-round-corrections.json; rebuild it.' }

$finalExplanationsFile = Join-Path $root 'data/curated/final-round-mcq-explanations.json'
if (-not (Test-Path -LiteralPath $finalExplanationsFile)) { throw 'Missing final-round-mcq-explanations.json' }
$finalExpPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath $finalExplanationsFile | ConvertFrom-Json
$finalExpItems = if ($finalExpPayload.items) { $finalExpPayload.items } else { $finalExpPayload }
if (@($finalExpItems).Count -ne 30) { throw 'final-round-mcq-explanations.json must contain exactly 30 items' }

if (@($derived.multipleChoice).Count -ne 30) { throw 'Final round must contain 30 MCQs.' }
if (@($derived.scenarios).Count -ne 20) { throw 'Final round must contain 20 scenarios.' }
if ($derived.provenance.renderStatus -notmatch 'not-rendered') { throw 'Render limitation must be recorded for final-round sources.' }
foreach ($question in @($derived.multipleChoice)) {
    if (@($question.options).Count -ne 4) { throw "$($question.id) must have four options." }
    if ($question.correctOption -notin @('A','B','C','D')) { throw "$($question.id) has no valid answer." }
    if ($question.id -eq 'final-mcq-22') {
        if ($question.verification.status -ne 'publicly-verified') { throw 'Final MCQ 22 must be publicly verified.' }
    } elseif ($question.verification.status -ne 'source-provided') { throw "$($question.id) lost source status." }
}
foreach ($scenario in @($derived.scenarios)) {
    if ([string]::IsNullOrWhiteSpace($scenario.prompt) -or [string]::IsNullOrWhiteSpace($scenario.answer)) { throw "$($scenario.id) is incomplete." }
    if ($scenario.id -in @('final-scenario-1','final-scenario-2')) {
        if ($scenario.verification.status -ne 'publicly-verified') { throw "$($scenario.id) must be publicly verified." }
    } elseif ($scenario.verification.status -ne 'source-provided') { throw "$($scenario.id) lost source status." }
}
$finalQuestions = @($derived.multipleChoice) + @($derived.scenarios)
if (@($finalQuestions | Where-Object { $_.verification.status -eq 'source-provided' }).Count -ne 47) { throw 'Exactly 47 final-round questions must remain source-provided after the third official correction.' }
if (@($finalQuestions | Where-Object { $_.verification.status -eq 'publicly-verified' }).Count -ne 3) { throw 'Exactly three corrected final-round questions must be publicly verified.' }
$scenario1 = $derived.scenarios | Where-Object id -eq 'final-scenario-1' | Select-Object -First 1
$scenario2 = $derived.scenarios | Where-Object id -eq 'final-scenario-2' | Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($scenario1.sourceAnswer) -or $scenario1.answer -notmatch 'phân biệt hai việc') { throw 'Scenario 1 correction/sourceAnswer was not preserved.' }
if ([string]::IsNullOrWhiteSpace($scenario2.sourceAnswer) -or $scenario2.answer -notmatch 'Chưa đủ căn cứ kết luận') { throw 'Scenario 2 correction/sourceAnswer was not preserved.' }
$scenario10 = $derived.scenarios | Where-Object id -eq 'final-scenario-10' | Select-Object -First 1
if ($scenario10.answer -match 'Quan điểm 2 đúng\.\s+11') { throw 'Scenario 10 contains a leaked page number artifact.' }
if (@($scenario1.verification.sourceIds | Where-Object { $_ -eq 'final-qd01-roles' }).Count -ne 1) { throw 'Scenario 1 official source is missing.' }
if (@($scenario2.verification.sourceIds | Where-Object { $_ -eq 'final-qd01-article5' }).Count -ne 1) { throw 'Scenario 2 official source is missing.' }
foreach ($sourceId in @('final-qd01-roles','final-qd01-article5','final-qd21-article6')) {
    $source = $bank.sources | Where-Object id -eq $sourceId | Select-Object -First 1
    if ($null -eq $source -or $source.url -notmatch '^https://') { throw "Official source URL is missing for $sourceId." }
}
$final22 = $derived.multipleChoice | Where-Object id -eq 'final-mcq-22' | Select-Object -First 1
if ($final22.correctOption -ne 'A' -or $final22.sourceAnswer -ne 'A') { throw 'Final MCQ 22 must retain DOCX answer A and display corrected answer A.' }
if (@($final22.verification.sourceIds | Where-Object { $_ -eq 'final-qd21-article6' }).Count -ne 1) { throw 'Final MCQ 22 official source is missing.' }

function Normalize-Text([string]$value) {
    return ([regex]::Replace($value.ToLowerInvariant().Trim(), '\s+', ' ')).TrimEnd('.', ' ', [char]0xA0)
}
$compiledFinal = @($bank.finalRound.multipleChoice)
foreach ($finalQuestion in $compiledFinal) {
    $matches = @($bank.multipleChoice | Where-Object { (Normalize-Text $_.prompt) -eq (Normalize-Text $finalQuestion.prompt) })
    if ($matches.Count -ne 1) { throw "Final MCQ $($finalQuestion.id) does not match exactly one question in the original bank." }
    $original = $matches[0]
    if ($original.correctOption -ne $finalQuestion.correctOption) { throw "Answer mismatch for duplicated prompt $($finalQuestion.id) / $($original.id)." }
    for ($index = 0; $index -lt 4; $index++) {
        if ((Normalize-Text $original.options[$index].text) -ne (Normalize-Text $finalQuestion.options[$index].text)) { throw "Option mismatch for duplicated prompt $($finalQuestion.id)." }
    }
}
$old23 = $bank.multipleChoice | Where-Object id -eq 'mcq-kiem-tra-giam-sat-23' | Select-Object -First 1
if ($old23.correctOption -ne 'A') { throw 'Original duplicated MCQ 23 must be corrected to A.' }
if ($bank.stats.total -ne 538 -or @($bank.multipleChoice).Count -ne 395 -or @($bank.oral).Count -ne 143) {
    throw 'The original 538-question bank changed while adding the final round.'
}
if ($bank.finalRound.stats.total -ne 50 -or @($bank.finalRound.multipleChoice).Count -ne 30 -or @($bank.finalRound.scenarios).Count -ne 20) {
    throw 'Compiled final round is incomplete.'
}
foreach ($sourceId in @('final-mcq-source','final-scenario-source')) {
    if (@($bank.sources | Where-Object id -eq $sourceId).Count -ne 1) { throw "Missing compiled source $sourceId." }
}
Write-Output 'Final round is complete: 30 selected MCQs matched to the original bank, 20 scenarios, 47 source-provided and 3 publicly verified; original 538 questions preserved.'
