Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
$ipremoted=read-host "link IP"
mstsc.exe /shadow:1 /v $ipremoted /control /prompt /noConsentPrompt