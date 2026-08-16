param(
    [string]$ExtractedPath = 'data/derived/extracted-document.json',
    [string]$OutputPath = 'data/derived/question-bank-base.json'
)

$ErrorActionPreference = 'Stop'

function Get-Slug {
    param([string]$Heading)
    switch -Regex ($Heading) {
        'VĂN PHÒNG' { return 'van-phong' }
        'TUYÊN GIÁO' { return 'tuyen-giao-dan-van' }
        'NỘI CHÍNH' { return 'noi-chinh' }
        'KIỂM TRA' { return 'kiem-tra-giam-sat' }
        'TỔ CHỨC' { return 'to-chuc-xay-dung-dang' }
        default { throw "Unknown section heading: $Heading" }
    }
}

function Get-SectionLabel {
    param([string]$Heading)
    return ($Heading -replace '^[IVX]+\.\s*', '').Trim()
}

function Clean-QuestionPrefix {
    param([string]$Text)
    return ($Text -replace '^\s*Câu\s+\d+\s*[\.:]\s*', '').Trim()
}

function Clean-OptionPrefix {
    param([string]$Text)
    return ($Text -replace '^\s*[A-D]\s*[\.\):\-]\s*', '').Trim()
}

$payload = Get-Content -Raw -LiteralPath $ExtractedPath | ConvertFrom-Json
$paragraphs = @($payload.blocks | Where-Object { $_.type -eq 'paragraph' } | ForEach-Object { $_.paragraph })
$nonEmpty = @($paragraphs | Where-Object { -not [string]::IsNullOrWhiteSpace($_.text) })

$partTwo = $paragraphs | Where-Object { $_.text -eq 'PHẦN THỨ HAI' } | Select-Object -First 1
if ($null -eq $partTwo) { throw 'Cannot locate PHẦN THỨ HAI' }
$partTwoIndex = [int]$partTwo.index

$sectionNodes = @($paragraphs | Where-Object { $_.text -match '^[IVX]+\.\s' })
$sections = @()
$mcq = @()
$oral = @()
$globalMcq = 0
$globalOral = 0

foreach ($sectionNode in $sectionNodes) {
    $sectionStart = [int]$sectionNode.index
    $nextSection = $sectionNodes | Where-Object { [int]$_.index -gt $sectionStart } | Select-Object -First 1
    $sectionEnd = if ($null -ne $nextSection) { [int]$nextSection.index } else { [int]::MaxValue }
    $kind = if ($sectionStart -lt $partTwoIndex) { 'multiple-choice' } else { 'oral' }
    if ($kind -eq 'multiple-choice' -and $sectionEnd -gt $partTwoIndex) {
        $sectionEnd = $partTwoIndex
    }
    $slug = Get-Slug $sectionNode.text
    $label = Get-SectionLabel $sectionNode.text
    $questionNodes = @($paragraphs | Where-Object {
        [int]$_.index -gt $sectionStart -and
        [int]$_.index -lt $sectionEnd -and
        $_.text -match '^\s*Câu\s+\d+\s*[\.:]'
    })

    $sections += [ordered]@{
        id = $slug
        label = $label
        kind = $kind
        questionCount = $questionNodes.Count
    }

    for ($questionOffset = 0; $questionOffset -lt $questionNodes.Count; $questionOffset++) {
        $questionNode = $questionNodes[$questionOffset]
        $questionStart = [int]$questionNode.index
        $questionEnd = if ($questionOffset + 1 -lt $questionNodes.Count) {
            [int]$questionNodes[$questionOffset + 1].index
        } else {
            $sectionEnd
        }
        if ($questionNode.text -notmatch '^\s*Câu\s+(\d+)') { throw "Cannot read question number at paragraph $questionStart" }
        $number = [int]$Matches[1]
        $reference = (($questionNode.runs | Where-Object { $_.italic } | ForEach-Object { $_.text }) -join '').Trim()

        if ($kind -eq 'multiple-choice') {
            $globalMcq++
            $optionNodes = @($paragraphs | Where-Object {
                [int]$_.index -gt $questionStart -and
                [int]$_.index -lt $questionEnd -and
                -not [string]::IsNullOrWhiteSpace($_.text)
            })
            $optionTexts = @()
            foreach ($optionNode in $optionNodes) {
                $matches = [regex]::Matches(
                    $optionNode.text,
                    '(?ms)^\s*[A-D]\s*[\.\):\-]\s*.*?(?=^\s*[A-D]\s*[\.\):\-]\s*|\z)'
                )
                if ($matches.Count -gt 1) {
                    $optionTexts += @($matches | ForEach-Object { $_.Value.Trim() })
                }
                else {
                    $optionTexts += $optionNode.text
                }
            }
            if ($optionTexts.Count -ne 4) {
                throw "Expected 4 options for $slug question $number, found $($optionTexts.Count)"
            }
            $options = @()
            for ($optionIndex = 0; $optionIndex -lt 4; $optionIndex++) {
                $options += [ordered]@{
                    id = @('A', 'B', 'C', 'D')[$optionIndex]
                    text = Clean-OptionPrefix $optionTexts[$optionIndex]
                }
            }
            $mcq += [ordered]@{
                id = "mcq-$slug-$number"
                globalNumber = $globalMcq
                sectionId = $slug
                section = $label
                number = $number
                prompt = Clean-QuestionPrefix $questionNode.text
                referenceText = $reference
                options = $options
                correctOption = $null
                explanation = $null
                verification = [ordered]@{ status = 'pending'; sourceIds = @() }
                sourceParagraph = $questionStart
            }
        }
        else {
            $globalOral++
            $bodyNodes = @($paragraphs | Where-Object {
                [int]$_.index -ge $questionStart -and
                [int]$_.index -lt $questionEnd -and
                -not [string]::IsNullOrWhiteSpace($_.text)
            })
            $body = @()
            for ($bodyIndex = 0; $bodyIndex -lt $bodyNodes.Count; $bodyIndex++) {
                $text = $bodyNodes[$bodyIndex].text.Trim()
                if ($bodyIndex -eq 0) { $text = Clean-QuestionPrefix $text }
                $body += $text
            }
            $oral += [ordered]@{
                id = "oral-$slug-$number-$globalOral"
                globalNumber = $globalOral
                sectionId = $slug
                section = $label
                number = $number
                prompt = ($body -join "`n`n")
                referenceText = $reference
                hint = $null
                answerOutline = @()
                memoryCue = $null
                verification = [ordered]@{ status = 'editorial'; sourceIds = @() }
                sourceParagraphs = @($bodyNodes | ForEach-Object { [int]$_.index })
            }
        }
    }
}

$result = [ordered]@{
    schemaVersion = 1
    generatedAt = [DateTime]::UtcNow.ToString('o')
    source = $payload.source
    stats = [ordered]@{
        multipleChoice = $mcq.Count
        oral = $oral.Count
        total = $mcq.Count + $oral.Count
    }
    sections = $sections
    multipleChoice = $mcq
    oral = $oral
}

$resolvedOutput = [IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($resolvedOutput)) | Out-Null
[IO.File]::WriteAllText(
    $resolvedOutput,
    ($result | ConvertTo-Json -Depth 20),
    [Text.UTF8Encoding]::new($false)
)
Write-Output "Built $($mcq.Count) multiple-choice and $($oral.Count) oral questions."
