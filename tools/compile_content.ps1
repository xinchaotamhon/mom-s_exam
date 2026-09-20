param(
    [string]$BankPath = 'data/derived/question-bank-base.json',
    [string]$PlanPath = 'data/curated/content-plan.json',
    [string]$SourcesPath = 'data/curated/sources.json',
    [string]$FinalRoundPath = 'data/derived/final-round.json',
    [string]$FinalCorrectionsPath = 'data/curated/final-round-corrections.json',
    [string]$McqExplanationsPath = 'data/curated/mcq-explanations.json',
    [string]$OralSchoolLinksPath = 'data/curated/oral-school-links.json',
    [string]$FinalScenarioSchoolLinksPath = 'data/curated/final-scenario-school-links.json',
    [string]$FinalMcqExplanationsPath = 'data/curated/final-round-mcq-explanations.json',
    [string]$OutputPath = 'site/data/question-bank.json'
)

$ErrorActionPreference = 'Stop'

function Add-UniqueValue {
    param([System.Collections.ArrayList]$List, [string]$Value)
    if (-not [string]::IsNullOrWhiteSpace($Value) -and -not $List.Contains($Value)) {
        [void]$List.Add($Value)
    }
}

function Get-QuestionSourceIds {
    param($Question)
    $text = "$($Question.prompt) $($Question.referenceText)"
    $ids = [System.Collections.ArrayList]::new()
    Add-UniqueValue $ids 'original-document'
    if ($text -match '01-QĐ/TW.+đảng phí|chế độ đảng phí') { Add-UniqueValue $ids 'qd-01-2026' }
    if ($text -match '399-QĐ/TW') { Add-UniqueValue $ids 'qd-399-2026' }
    if ($text -match '05-HD/VPTW') { Add-UniqueValue $ids 'hd-05-2026' }
    if ($text -match '117/2025/QH15|Bảo vệ bí mật nhà nước') { Add-UniqueValue $ids 'law-117-2025' }
    if ($text -match '42-HD/BTCTW') { Add-UniqueValue $ids 'hd-42-2025' }
    if ($text -match '208-QĐ/TW') { Add-UniqueValue $ids 'qd-208-2026' }
    if ($text -match '01-HD/TW') { Add-UniqueValue $ids 'hd-01-2026' }
    if ($text -match '350-QĐ/TW') { Add-UniqueValue $ids 'qd-350-2025' }
    if ($text -match '21-KL/TW') { Add-UniqueValue $ids 'kl-21-2021' }
    return @($ids)
}

function Test-LocalSourceQuestion {
    param($Question)
    $text = "$($Question.prompt) $($Question.referenceText)"
    return $text -match '(?i)(Tỉnh ủy|tỉnh Lào Cai|QĐ/TU|ĐA/TU|Đ/TU|NQ/TU|CT/TU|QC/TU)'
}

function Find-PublicReview {
    param($Question, $Ranges)
    return $Ranges | Where-Object {
        $_.sectionId -eq $Question.sectionId -and
        [int]$Question.number -ge [int]$_.from -and
        [int]$Question.number -le [int]$_.to
    } | Select-Object -First 1
}

function Get-Theme {
    param([string]$Text)
    switch -Regex ($Text) {
        '(?i)đảng phí|thu phí|nộp phí' { return 'party-fee' }
        '(?i)bí mật|mật nhà nước|tài liệu mật|văn bản|con dấu|lưu trữ' { return 'records' }
        '(?i)deepfake|trí tuệ nhân tạo|mạng xã hội|thông tin xấu|tin giả|không gian mạng' { return 'digital' }
        '(?i)tôn giáo|tín ngưỡng|thờ cúng|già làng|trưởng bản' { return 'faith-community' }
        '(?i)hiến đất|mở rộng đường|nhà văn hóa|nông thôn mới|môi trường|vứt rác|nước thải|công trình|tranh chấp đất|đền bù|mặt bằng|xô xát|lấn sang|mái hiên' { return 'community' }
        '(?i)tham nhũng|lãng phí|tiêu cực|tài sản|kê khai|suy thoái|đánh bạc|bạo lực|quà tặng|chạy chức|chạy quyền' { return 'integrity' }
        '(?i)kiểm tra|giám sát|kỷ luật|tố cáo|vi phạm' { return 'inspection' }
        '(?i)cán bộ|bổ nhiệm|quy hoạch|đánh giá|xếp loại|đào tạo' { return 'personnel' }
        '(?i)kết nạp|đảng viên|chuyển sinh hoạt|thẻ đảng|huy hiệu|người xin vào Đảng|quần chúng' { return 'membership' }
        '(?i)sinh hoạt chi bộ|họp chi bộ|nghị quyết|biểu quyết|chi ủy|đại hội|đại biểu|kiểm phiếu|bầu cử' { return 'meeting' }
        '(?i)dân vận|dư luận|tuyên truyền|nhân dân|người dân|công dân|hộ dân|thôn|tổ dân phố|phản biện xã hội|đơn thư|kiến nghị' { return 'people' }
        default { return 'general' }
    }
}

function Get-MemoryCue {
    param([string]$Theme)
    switch ($Theme) {
        'party-fee' { return 'Đúng người → đúng mức → đúng chứng từ → đúng thời hạn.' }
        'records' { return 'Phân loại → thẩm quyền → bảo vệ → lưu vết.' }
        'digital' { return 'Dừng chia sẻ → kiểm chứng → báo cáo → dùng nguồn chính thống.' }
        'faith-community' { return 'Tôn trọng niềm tin → đúng pháp luật → vận động, không ép buộc → giữ đoàn kết.' }
        'community' { return 'Nghe đủ bên → công khai căn cứ → hòa giải → xử lý đúng thẩm quyền → theo dõi.' }
        'people' { return 'Nghe dân → xác minh → giải thích → xử lý → phản hồi.' }
        'integrity' { return 'Giữ chứng cứ → báo đúng nơi → không bao che → theo dõi kết quả.' }
        'inspection' { return 'Đúng thẩm quyền → đúng quy trình → đủ chứng cứ → khách quan.' }
        'personnel' { return 'Tiêu chuẩn → tập thể → quy trình → hồ sơ → thẩm quyền.' }
        'membership' { return 'Điều kiện → hồ sơ → chi bộ → cấp ủy → theo dõi.' }
        'meeting' { return 'Chuẩn bị → dân chủ → biểu quyết → phân công → kiểm tra.' }
        default { return 'Kết luận → căn cứ → cách làm → phòng ngừa.' }
    }
}

function Get-PracticalAction {
    param([string]$Theme)
    switch ($Theme) {
        'party-fee' { return 'Đối chiếu đối tượng, mức đóng và thời điểm; phân công người theo dõi; lập chứng từ, công khai và nộp đúng hạn.' }
        'records' { return 'Xác định độ mật hoặc loại văn bản trước; chỉ giao đúng người có thẩm quyền; ghi nhận việc bàn giao, lưu và thu hồi.' }
        'digital' { return 'Không phát tán thêm; kiểm tra nguồn, thời điểm và dấu hiệu cắt ghép; lưu bằng chứng rồi báo đầu mối có trách nhiệm.' }
        'faith-community' { return 'Tôn trọng quyền tự do tín ngưỡng nhưng không chấp nhận mua chuộc, ép buộc hoặc xúc phạm; xác minh, tuyên truyền pháp luật và phối hợp chính quyền xử lý đúng thẩm quyền.' }
        'community' { return 'Không áp đặt hoặc để đám đông tự xử; gặp riêng các bên, công khai hồ sơ và mức đóng góp, tổ chức hòa giải; việc có dấu hiệu vi phạm phải chuyển đúng cơ quan chuyên môn xử lý.' }
        'people' { return 'Tiếp nhận bình tĩnh, hỏi rõ sự việc, phân loại đúng thẩm quyền, hẹn thời gian phản hồi và theo dõi đến khi có kết quả.' }
        'integrity' { return 'Bảo toàn tài liệu, không tự ý kết luận hoặc che giấu; báo cáo đúng cấp, bảo vệ người phản ánh và kiến nghị biện pháp ngăn hậu quả.' }
        'inspection' { return 'Xác định chủ thể, đối tượng và thẩm quyền; thu thập chứng cứ hai chiều; thực hiện đủ bước, thời hạn và quyền giải trình.' }
        'personnel' { return 'Đối chiếu tiêu chuẩn và điều kiện; để tập thể thảo luận dân chủ; hoàn thiện hồ sơ rồi trình đúng cấp quyết định.' }
        'membership' { return 'Kiểm tra điều kiện và hồ sơ; để chi bộ xem xét, biểu quyết; báo cấp ủy có thẩm quyền và tiếp tục quản lý sau quyết định.' }
        'meeting' { return 'Chuẩn bị nội dung trước; tạo điều kiện tranh luận thẳng thắn; kết luận bằng biểu quyết, ghi biên bản và giao người, giao hạn.' }
        default { return 'Nêu việc phải làm ngay, người chịu trách nhiệm, thời hạn hoàn thành và cách kiểm tra kết quả.' }
    }
}

function New-OralSupport {
    param($Question)
    $theme = Get-Theme $Question.prompt
    $hasViews = $Question.prompt -match '(?i)quan điểm|ý kiến|đúng hay sai|đồng ý'
    $hint = if ($hasViews) {
        'Đừng chọn theo sự thuận tiện. Hãy tìm điều kiện bắt buộc trong đề, rồi đối chiếu lần lượt: thẩm quyền, trình tự và trách nhiệm.'
    } else {
        'Hãy trả lời theo bốn nhịp: kết luận ngắn, căn cứ chính, việc làm ngay và cách phòng ngừa lặp lại.'
    }
    $outline = @(
        'Kết luận ngay ở câu đầu: đồng ý hay không đồng ý, đúng hay sai, hoặc chọn phương án xử lý nào.',
        'Nêu đúng tên văn bản hoặc nguyên tắc đã được đề bài viện dẫn; nếu chưa nhớ số điều, không nên tự đoán số điều.',
        (Get-PracticalAction $theme),
        'Nói rõ ai báo cáo ai, việc nào làm trước, mốc thời gian hoặc hồ sơ nào cần lưu.',
        'Chốt bằng biện pháp phòng ngừa: phổ biến lại quy định, phân công theo dõi và kiểm tra việc khắc phục.'
    )
    return [ordered]@{
        hint = $hint
        memoryCue = Get-MemoryCue $theme
        answerOutline = $outline
        theme = $theme
    }
}

function Normalize-QuestionText {
    param([string]$Value)
    return ([regex]::Replace($Value.ToLowerInvariant().Replace([char]0xA0, ' ').Trim(), '\s+', ' ')).TrimEnd('.', ' ')
}

function New-ItemMap {
    param($Items, [string]$Label)
    $map = @{}
    foreach ($item in @($Items)) {
        $id = [string]$item.questionId
        if ([string]::IsNullOrWhiteSpace($id)) { throw "$Label contains an item without questionId." }
        if ($map.ContainsKey($id)) { throw "$Label contains duplicate questionId: $id" }
        $map[$id] = $item
    }
    return $map
}

$bank = Get-Content -Raw -Encoding UTF8 -LiteralPath $BankPath | ConvertFrom-Json
$plan = Get-Content -Raw -Encoding UTF8 -LiteralPath $PlanPath | ConvertFrom-Json
$sourcePayload = Get-Content -Raw -Encoding UTF8 -LiteralPath $SourcesPath | ConvertFrom-Json
$finalRound = Get-Content -Raw -Encoding UTF8 -LiteralPath $FinalRoundPath | ConvertFrom-Json
$finalCorrections = Get-Content -Raw -Encoding UTF8 -LiteralPath $FinalCorrectionsPath | ConvertFrom-Json
$mcqExplanationPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath $McqExplanationsPath | ConvertFrom-Json
$oralSchoolPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath $OralSchoolLinksPath | ConvertFrom-Json
$finalScenarioSchoolPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath $FinalScenarioSchoolLinksPath | ConvertFrom-Json
$finalMcqExplanationPayload = Get-Content -Raw -Encoding UTF8 -LiteralPath $FinalMcqExplanationsPath | ConvertFrom-Json
$mcqExplanationMap = New-ItemMap $mcqExplanationPayload.items 'MCQ explanations'
$oralSchoolMap = New-ItemMap $oralSchoolPayload.items 'Oral school links'
$finalScenarioSchoolMap = New-ItemMap $finalScenarioSchoolPayload.items 'Final scenario school links'
$finalMcqItems = if ($finalMcqExplanationPayload.items) { $finalMcqExplanationPayload.items } else { $finalMcqExplanationPayload }
$finalMcqExplanationMap = New-ItemMap $finalMcqItems 'Final MCQ explanations'
if (@($finalRound.multipleChoice).Count -ne 30 -or @($finalRound.scenarios).Count -ne 20) {
    throw 'Final round must contain exactly 30 multiple-choice questions and 20 scenarios.'
}
$publicRanges = @($plan.reviewPolicy.publiclyVerified)

foreach ($sectionProperty in $plan.answerSequences.PSObject.Properties) {
    $sectionId = $sectionProperty.Name
    $letters = ([regex]::Replace([string]$sectionProperty.Value, '\s', '')).ToCharArray()
    $questions = @($bank.multipleChoice | Where-Object sectionId -eq $sectionId | Sort-Object number)
    if ($letters.Count -ne $questions.Count) {
        throw "Answer count mismatch for ${sectionId}: $($letters.Count) answers for $($questions.Count) questions."
    }
    for ($index = 0; $index -lt $questions.Count; $index++) {
        $question = $questions[$index]
        $answer = [string]$letters[$index]
        if ($answer -notin @('A', 'B', 'C', 'D')) { throw "Invalid answer $answer for $($question.id)" }
        $selected = $question.options | Where-Object id -eq $answer | Select-Object -First 1
        $sourceIds = [System.Collections.ArrayList]::new()
        foreach ($sourceId in @(Get-QuestionSourceIds $question)) { Add-UniqueValue $sourceIds $sourceId }
        $publicReview = Find-PublicReview $question $publicRanges
        if ($null -ne $publicReview) {
            foreach ($sourceId in @($publicReview.sourceIds)) { Add-UniqueValue $sourceIds $sourceId }
        }
        $status = if ($null -ne $publicReview) { 'publicly-verified' } elseif (Test-LocalSourceQuestion $question) { 'local-source-needed' } else { 'cross-checked' }
        $note = switch ($status) {
            'publicly-verified' { 'Đã đối chiếu với nguồn công khai nêu kèm câu hỏi.' }
            'local-source-needed' { 'Đáp án đã được rà theo nội dung và tính nhất quán của ngân hàng câu hỏi; nên đối chiếu thêm bản văn bản nội bộ của Tỉnh ủy Lào Cai nếu có.' }
            default { 'Đã rà nội dung và nguồn tham khảo công khai; nên ưu tiên bản văn bản chính thức mới nhất khi ôn thi.' }
        }
        $theme = Get-Theme $question.prompt
        $question.correctOption = $answer
        $question.explanation = "Đáp án $answer. $($selected.text)"
        $question.verification.status = $status
        $question.verification.sourceIds = @($sourceIds)
        $question.verification | Add-Member -NotePropertyName note -NotePropertyValue $note -Force
        $question | Add-Member -NotePropertyName memoryCue -NotePropertyValue (Get-MemoryCue $theme) -Force
    }
}

foreach ($question in @($bank.oral)) {
    $support = New-OralSupport $question
    $question.hint = $support.hint
    $question.memoryCue = $support.memoryCue
    $question.answerOutline = @($support.answerOutline)
    $question | Add-Member -NotePropertyName theme -NotePropertyValue $support.theme -Force
    $question.verification.status = 'editorial-support'
    $question.verification.sourceIds = @(Get-QuestionSourceIds $question)
    $question.verification | Add-Member -NotePropertyName note -NotePropertyValue 'Khung gợi ý do biên tập viên soạn để luyện cách trình bày; không phải đáp án mẫu chính thức của Ban Tổ chức.' -Force
}

foreach ($correction in @($finalCorrections.corrections | Where-Object { $_.bankQuestionId -and $_.correctedOption })) {
    $question = $bank.multipleChoice | Where-Object id -eq $correction.bankQuestionId | Select-Object -First 1
    if ($null -eq $question) { throw "Final-round correction target not found: $($correction.bankQuestionId)" }
    $question | Add-Member -NotePropertyName sourceAnswer -NotePropertyValue $question.correctOption -Force
    $question.correctOption = [string]$correction.correctedOption
    $selected = $question.options | Where-Object id -eq $question.correctOption | Select-Object -First 1
    $question.explanation = "Đáp án $($question.correctOption). $($selected.text)"
    $question | Add-Member -NotePropertyName correction -NotePropertyValue ([ordered]@{
        note = $correction.correctionNote
        sourceIds = @('original-document', 'final-mcq-source') + @($correction.sourceIds)
        status = 'publicly-verified'
    }) -Force
    $question.verification.status = 'publicly-verified'
    $question.verification.sourceIds = @('original-document', 'final-mcq-source') + @($correction.sourceIds)
    $question.verification.note = 'Đáp án đã hiệu chỉnh theo nguồn công khai chính thức; câu hỏi gốc vẫn được giữ nguyên.'
}

foreach ($question in @($bank.multipleChoice)) {
    $support = $mcqExplanationMap[$question.id]
    if ($null -eq $support -or [string]::IsNullOrWhiteSpace($support.shortExplanation)) {
        throw "Missing concise explanation for $($question.id)."
    }
    $question.explanation = [string]$support.shortExplanation
    $question | Add-Member -NotePropertyName explanationKind -NotePropertyValue 'concise-oral-rationale' -Force
}

$schoolSourceIds = @('son-thinh-current-locality', 'son-thinh-school-context', 'son-thinh-digital-context')
foreach ($question in @($bank.oral)) {
    $support = $oralSchoolMap[$question.id]
    if ($null -eq $support -or [string]::IsNullOrWhiteSpace($support.schoolApplication)) {
        throw "Missing school application for $($question.id)."
    }
    $question | Add-Member -NotePropertyName schoolApplication -NotePropertyValue ([string]$support.schoolApplication) -Force
    $question | Add-Member -NotePropertyName schoolApplicationSourceIds -NotePropertyValue $schoolSourceIds -Force
}

foreach ($scenario in @($finalRound.scenarios)) {
    $support = $finalScenarioSchoolMap[$scenario.id]
    if ($null -eq $support -or [string]::IsNullOrWhiteSpace($support.schoolApplication)) {
        throw "Missing school application for $($scenario.id)."
    }
    $scenario | Add-Member -NotePropertyName schoolApplication -NotePropertyValue ([string]$support.schoolApplication) -Force
    $scenario | Add-Member -NotePropertyName schoolApplicationSourceIds -NotePropertyValue $schoolSourceIds -Force
}

foreach ($finalQuestion in @($finalRound.multipleChoice)) {
    $support = $finalMcqExplanationMap[$finalQuestion.id]
    if ($null -eq $support -or [string]::IsNullOrWhiteSpace($support.shortExplanation)) {
        throw "Missing concise explanation for final MCQ $($finalQuestion.id)."
    }
    $finalQuestion.explanation = [string]$support.shortExplanation
    $finalQuestion | Add-Member -NotePropertyName explanationKind -NotePropertyValue 'concise-oral-rationale' -Force
}

$reviewStats = [ordered]@{}
foreach ($status in @('publicly-verified', 'cross-checked', 'local-source-needed')) {
    $reviewStats[$status] = @($bank.multipleChoice | Where-Object { $_.verification.status -eq $status }).Count
}
$bank | Add-Member -NotePropertyName reviewStats -NotePropertyValue $reviewStats -Force
$finalSources = @(
    [ordered]@{
        id = 'final-mcq-source'
        title = '30 trắc nghiệm vòng thi cuối (tài liệu DOCX cung cấp)'
        url = $null
        kind = 'source-document'
        note = "Bản sao bất biến: $($finalRound.provenance.sources.'final-mcq-source'.sha256)."
    }
    [ordered]@{
        id = 'final-scenario-source'
        title = '20 tình huống kèm đáp án vòng thi cuối (tài liệu DOCX cung cấp)'
        url = $null
        kind = 'source-document'
        note = "Bản sao bất biến: $($finalRound.provenance.sources.'final-scenario-source'.sha256)."
    }
)
$finalSources += @($finalCorrections.sources)
$bank | Add-Member -NotePropertyName sources -NotePropertyValue @($sourcePayload.sources) -Force
$bank | Add-Member -NotePropertyName applicationContext -NotePropertyValue ([ordered]@{
    schoolName = 'Trường Mầm non Sơn Thịnh'
    localityLabel = [string]$oralSchoolPayload.localityLabel
    note = 'Các đoạn liên hệ là ví dụ vận dụng để trình bày, không phải ghi nhận sự việc đã xảy ra tại trường.'
    sourceIds = $schoolSourceIds
}) -Force
$bank | Add-Member -NotePropertyName finalRound -NotePropertyValue ([ordered]@{
    stats = $finalRound.stats
    multipleChoice = @($finalRound.multipleChoice)
    scenarios = @($finalRound.scenarios)
    provenance = $finalRound.provenance
    corrections = @($finalCorrections.corrections | ForEach-Object { $_.questionId })
}) -Force
$bank.sources = @($bank.sources) + $finalSources
$bank | Add-Member -NotePropertyName contentNotice -NotePropertyValue 'Ứng dụng hỗ trợ ôn tập. Khi đáp án liên quan văn bản nội bộ hoặc văn bản vừa được sửa đổi, hãy ưu tiên tài liệu chính thức của Ban Tổ chức.' -Force

$resolvedOutput = [IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($resolvedOutput)) | Out-Null
[IO.File]::WriteAllText(
    $resolvedOutput,
    ($bank | ConvertTo-Json -Depth 30),
    [Text.UTF8Encoding]::new($false)
)
Write-Output "Compiled $($bank.stats.total) questions to $OutputPath. Review: $($reviewStats | ConvertTo-Json -Compress)"
