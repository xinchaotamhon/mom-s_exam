$ErrorActionPreference = 'Stop'

& (Join-Path $PSScriptRoot '..\tools\compile_content.ps1') | Out-Null
$bank = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot '..\site\data\question-bank.json') | ConvertFrom-Json

if ($bank.stats.total -ne 538) { throw 'Expected 538 compiled questions.' }
if (@($bank.multipleChoice).Count -ne 395) { throw 'Expected 395 multiple-choice questions.' }
if (@($bank.oral).Count -ne 143) { throw 'Expected 143 oral questions.' }
if (@($bank.multipleChoice | Where-Object { $_.correctOption -notin @('A','B','C','D') }).Count -ne 0) { throw 'Every MCQ must have one valid answer.' }
if (@($bank.multipleChoice | Where-Object { [string]::IsNullOrWhiteSpace($_.explanation) }).Count -ne 0) { throw 'Every MCQ must have an explanation.' }
if (@($bank.oral | Where-Object { [string]::IsNullOrWhiteSpace($_.hint) -or $_.answerOutline.Count -lt 4 }).Count -ne 0) { throw 'Every oral question needs a practical hint and outline.' }

$checks = @{
    'mcq-van-phong-1' = 'A'
    'mcq-van-phong-34' = 'D'
    'mcq-tuyen-giao-dan-van-55' = 'C'
    'mcq-tuyen-giao-dan-van-57' = 'C'
    'mcq-tuyen-giao-dan-van-65' = 'D'
    'mcq-noi-chinh-6' = 'C'
    'mcq-noi-chinh-9' = 'C'
    'mcq-to-chuc-xay-dung-dang-51' = 'B'
    'mcq-to-chuc-xay-dung-dang-102' = 'C'
    'mcq-to-chuc-xay-dung-dang-146' = 'C'
}
foreach ($entry in $checks.GetEnumerator()) {
    $question = $bank.multipleChoice | Where-Object id -eq $entry.Key | Select-Object -First 1
    if ($null -eq $question -or $question.correctOption -ne $entry.Value) {
        throw "Curated answer regression for $($entry.Key)."
    }
}

if (($bank.reviewStats.'publicly-verified' + $bank.reviewStats.'cross-checked' + $bank.reviewStats.'local-source-needed') -ne 395) {
    throw 'Review status counts must cover all MCQs.'
}

Write-Output 'Curated content is complete: 395 answers and 143 practical oral hints.'
