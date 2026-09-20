$ErrorActionPreference = 'Stop'
$operatorName = (Read-Host 'Developer / operator name (public)').Trim()
$contactEmail = (Read-Host 'Contact email (public)').Trim()
$publicationDate = (Read-Host 'Publication date YYYY-MM-DD').Trim()
if (!$operatorName -or $contactEmail -notmatch '^[^\s@]+@[^\s@]+\.[^\s@]+$') { throw 'Provide a name and valid contact email.' }
$parsedDate = [datetime]::MinValue
if (![datetime]::TryParseExact($publicationDate,'yyyy-MM-dd',[cultureinfo]::InvariantCulture,[Globalization.DateTimeStyles]::None,[ref]$parsedDate)) { throw 'Use date YYYY-MM-DD.' }
if ((Read-Host 'Have you reviewed the documents? Type YES to fill the pages') -cne 'YES') { exit }
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($fileName in @('index.html','terms.html','privacy.html')) {
    $filePath = Join-Path $PSScriptRoot $fileName
    $text = [IO.File]::ReadAllText($filePath)
    $text = $text.Replace('[[DEVELOPER_NAME]]',[Net.WebUtility]::HtmlEncode($operatorName)).Replace('[[CONTACT_EMAIL]]',[Net.WebUtility]::HtmlEncode($contactEmail)).Replace('[[PUBLICATION_DATE]]',$publicationDate)
    $text = [regex]::Replace($text,'(?s)<!-- DRAFT-BEGIN -->.*?<!-- DRAFT-END -->','')
    [IO.File]::WriteAllText($filePath,$text,$utf8)
}
Write-Host 'Pages prepared locally. Nothing has been uploaded.'
