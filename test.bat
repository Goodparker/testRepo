# ВСТАВЬ СЮДА СВОЙ ТОКЕН
$Token = "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"

$Repo = "Goodparker/testRepo"
$Branch = "main"
$File = "file.txt"

if (-not $Token -or $Token -eq "") {
    Write-Host "Токен не задан"
    exit 1
}

# создаём файл
"Hello $(Get-Date)" | Out-File -Encoding ascii $File

# кодируем
$Bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $File))
$Content = [Convert]::ToBase64String($Bytes)

$Uri = "https://api.github.com/repos/$Repo/contents/$File"

$Headers = @{
    Authorization = "token $Token"
    Accept = "application/vnd.github+json"
    "User-Agent" = "UploaderScript"
}

try {
    # проверяем существует ли файл
    $Existing = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers

    $Body = @{
        message = "update file"
        content = $Content
        branch  = $Branch
        sha     = $Existing.sha
    } | ConvertTo-Json -Depth 10

    Write-Host "Обновляем файл..."
}
catch {
    $Body = @{
        message = "create file"
        content = $Content
        branch  = $Branch
    } | ConvertTo-Json -Depth 10

    Write-Host "Создаём файл..."
}

Invoke-RestMethod -Method Put -Uri $Uri -Headers $Headers -Body $Body -ContentType "application/json"

Write-Host "Готово"
