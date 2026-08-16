param(
    [Parameter(Mandatory = $true)]
    [string]$DocxPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

$wordNamespace = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

function Get-WordAttribute {
    param(
        [System.Xml.XmlNode]$Node,
        [string]$LocalName
    )

    if ($null -eq $Node) { return $null }
    $attribute = $Node.Attributes.GetNamedItem($LocalName, $wordNamespace)
    if ($null -eq $attribute) { return $null }
    return $attribute.Value
}

function Select-WordNode {
    param(
        [System.Xml.XmlNode]$Node,
        [string]$XPath,
        [System.Xml.XmlNamespaceManager]$NamespaceManager
    )

    if ($null -eq $Node) { return $null }
    return $Node.SelectSingleNode($XPath, $NamespaceManager)
}

function Get-ParagraphData {
    param(
        [System.Xml.XmlNode]$Paragraph,
        [System.Xml.XmlNamespaceManager]$NamespaceManager,
        [int]$Index,
        [string]$Context
    )

    $runData = @()
    foreach ($run in $Paragraph.SelectNodes('./w:r | ./w:hyperlink/w:r', $NamespaceManager)) {
        $parts = @()
        foreach ($contentNode in $run.SelectNodes('.//w:t | .//w:tab | .//w:br', $NamespaceManager)) {
            switch ($contentNode.LocalName) {
                't' { $parts += $contentNode.InnerText }
                'tab' { $parts += "`t" }
                'br' { $parts += "`n" }
            }
        }
        $text = $parts -join ''
        if ($text.Length -eq 0) { continue }
        $properties = $run.SelectSingleNode('./w:rPr', $NamespaceManager)
        $runData += [ordered]@{
            text = $text
            bold = $null -ne (Select-WordNode $properties './w:b' $NamespaceManager)
            italic = $null -ne (Select-WordNode $properties './w:i' $NamespaceManager)
            underline = $null -ne (Select-WordNode $properties './w:u' $NamespaceManager)
            color = Get-WordAttribute (Select-WordNode $properties './w:color' $NamespaceManager) 'val'
            highlight = Get-WordAttribute (Select-WordNode $properties './w:highlight' $NamespaceManager) 'val'
        }
    }

    $paragraphProperties = $Paragraph.SelectSingleNode('./w:pPr', $NamespaceManager)
    [ordered]@{
        index = $Index
        context = $Context
        text = (($runData | ForEach-Object { $_.text }) -join '')
        style = Get-WordAttribute (Select-WordNode $paragraphProperties './w:pStyle' $NamespaceManager) 'val'
        numbering = [ordered]@{
            numId = Get-WordAttribute (Select-WordNode $paragraphProperties './w:numPr/w:numId' $NamespaceManager) 'val'
            level = Get-WordAttribute (Select-WordNode $paragraphProperties './w:numPr/w:ilvl' $NamespaceManager) 'val'
        }
        runs = $runData
    }
}

$resolvedDocx = (Resolve-Path -LiteralPath $DocxPath).Path
$resolvedOutput = [IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
$outputDirectory = [IO.Path]::GetDirectoryName($resolvedOutput)
[IO.Directory]::CreateDirectory($outputDirectory) | Out-Null

$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedDocx)
try {
    $entry = $archive.GetEntry('word/document.xml')
    if ($null -eq $entry) { throw 'DOCX does not contain word/document.xml' }

    $reader = [IO.StreamReader]::new($entry.Open())
    try { [xml]$document = $reader.ReadToEnd() }
    finally { $reader.Dispose() }

    $namespaceManager = [System.Xml.XmlNamespaceManager]::new($document.NameTable)
    $namespaceManager.AddNamespace('w', $wordNamespace)
    $body = $document.SelectSingleNode('//w:body', $namespaceManager)
    $blocks = @()
    $paragraphIndex = 0
    $tableIndex = 0

    foreach ($child in $body.ChildNodes) {
        if ($child.NamespaceURI -ne $wordNamespace) { continue }
        if ($child.LocalName -eq 'p') {
            $blocks += [ordered]@{
                type = 'paragraph'
                paragraph = Get-ParagraphData $child $namespaceManager $paragraphIndex 'body'
            }
            $paragraphIndex++
            continue
        }
        if ($child.LocalName -eq 'tbl') {
            $rows = @()
            $rowIndex = 0
            foreach ($row in $child.SelectNodes('./w:tr', $namespaceManager)) {
                $cells = @()
                $cellIndex = 0
                foreach ($cell in $row.SelectNodes('./w:tc', $namespaceManager)) {
                    $paragraphs = @()
                    foreach ($paragraph in $cell.SelectNodes('./w:p', $namespaceManager)) {
                        $paragraphs += Get-ParagraphData $paragraph $namespaceManager $paragraphIndex "table:$tableIndex,row:$rowIndex,cell:$cellIndex"
                        $paragraphIndex++
                    }
                    $cells += [ordered]@{ index = $cellIndex; paragraphs = $paragraphs }
                    $cellIndex++
                }
                $rows += [ordered]@{ index = $rowIndex; cells = $cells }
                $rowIndex++
            }
            $blocks += [ordered]@{ type = 'table'; index = $tableIndex; rows = $rows }
            $tableIndex++
        }
    }

    $sourceInfo = Get-Item -LiteralPath $resolvedDocx
    $payload = [ordered]@{
        schemaVersion = 1
        extractedAt = [DateTime]::UtcNow.ToString('o')
        source = [ordered]@{
            originalName = $sourceInfo.Name
            byteLength = $sourceInfo.Length
            sha256 = (Get-FileHash -LiteralPath $resolvedDocx -Algorithm SHA256).Hash.ToLowerInvariant()
        }
        stats = [ordered]@{
            paragraphs = $paragraphIndex
            tables = $tableIndex
            blocks = $blocks.Count
        }
        blocks = $blocks
    }

    $json = $payload | ConvertTo-Json -Depth 20
    [IO.File]::WriteAllText($resolvedOutput, $json, [Text.UTF8Encoding]::new($false))
    Write-Output "Extracted $paragraphIndex paragraphs and $tableIndex tables to $resolvedOutput"
}
finally {
    $archive.Dispose()
}
