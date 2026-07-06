# sign-and-install.ps1
# Запускать от имени администратора!

$packageName = "Милорды"
$packagePath = "C:\Users\demid\Downloads\Милорды"
$certPath = "$packagePath\milordy.pfx"
$password = "123456"

Write-Host "=== Установка сертификата ===" -ForegroundColor Cyan

# Устанавливаем сертификат в доверенные
Import-Certificate -FilePath "$packagePath\milordy.cer" -CertStoreLocation Cert:\LocalMachine\Root -Force

Write-Host "✓ Сертификат установлен" -ForegroundColor Green

Write-Host "`n=== Подпись пакета ===" -ForegroundColor Cyan

# Подписываем пакет
if (Test-Path "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe") {
    $signTool = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" | Select-Object -First 1
    & $signTool.FullName sign /fd SHA256 /a /f $certPath /p $password /t http://timestamp.digicert.com "$packagePath\$packageName.msixbundle"
    Write-Host "✓ Пакет подписан" -ForegroundColor Green
} else {
    Write-Host "⚠ SignTool не найден. Скачай Windows SDK: https://developer.microsoft.com/windows/downloads/windows-10-sdk/" -ForegroundColor Yellow
}

Write-Host "`n=== Установка приложения ===" -ForegroundColor Cyan

# Устанавливаем приложение
try {
    Add-AppxPackage -Path "$packagePath\$packageName.msixbundle" -ForceUpdateFromAnyVersion
    Write-Host "✓ Приложение установлено успешно!" -ForegroundColor Green
    Write-Host "`n🎉 Запускай 'Милорды' из меню Пуск!" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Ошибка установки: $_" -ForegroundColor Red
}

Write-Host "`nНажми любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
