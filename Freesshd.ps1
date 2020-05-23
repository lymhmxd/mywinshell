# 20200523V1
# author mengxd
$status = 1 # 0:need transfer file 1: No need transfer file
$path = Split-Path -Parent $MyInvocation.MyCommand.Definition
$logfile = $path + "\psscript.log" # log file in local pc
# update script
try {
    $client = New-Object System.Net.WebClient
    $client.Credentials = New-Object System.N et.NetworkCredential("administrator", "tiens_123")
    $client.DownloadFile("ftp://192.168.2.237/freesshdlog/Freesshd.ps1", $path + "\Freesshd.ps1")
    "$(get-date)" + " Upgrade script succeeded." | Out-File -Append $logfile -Encoding UTF8
}
catch {
    "$(get-date)" + " Upgrade script failed." | Out-File -Append $logfile -Encoding UTF8
}
if ((Get-Service *FreeSSHDService* | Select-Object DisplayName).DisplayName -eq "FreeSSHDService") {
    try {
        $localaddr = (ipconfig.exe | findstr "IPv4").split(":")[1].Trim(" .-`t`n`r")
    }
    catch {
        "$(get-date)" + " The network it missing." | Out-File -Append $logfile -Encoding UTF8
        exit
    }
    $result = netstat -ano | findstr 0.0.0.0:22
    if ($result -like "*TCP*") {
        # "$(get-date)" + " FreeSSHDservice Is running..." | Out-File -Append $logfile -Encoding UTF8
        $status = 0 # FreeSSHDservice is working fine, no need to restart service.
    }
    else {
        "$(get-date)" + " FreeSSHDservice Is stopped. Now trying to restart this service." | Out-File -Append $logfile -Encoding UTF8
        try {
            restart-service FreeSSHDservice
            "$(get-date)" + " FreeSSHDservice Is Working now." | Out-File -Append $logfile -Encoding UTF8
        }
        catch {
            "$(get-date)" + " Restart FreeSSHDservice is wrong." | Out-File -Append $logfile -Encoding UTF8
        }
    }
}
else {
    "$(get-date)" + " FreeSSHDservice is missing. " | Out-File -Append $logfile -Encoding UTF8
}
# push log file to ftp
if ($status -eq 1) {
    try {
        $client = New-Object System.Net.WebClient
        $client.Credentials = New-Object System.Net.NetworkCredential("administrator", "tiens_123")
        $client.UploadFile("ftp://192.168.2.237/freesshdlog/" + $localaddr + ".log", $logfile)
    }
    catch {
        "$(get-date)" + " Connect to FTP server failed." | Out-File -Append $logfile -Encoding UTF8
    }
}
exit