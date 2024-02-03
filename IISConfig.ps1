import-module servermanager
add-windowsfeature web-server -includeallsubfeature
add-windowsfeature Web-ASP-Net45
add-windowsfeature NET-framework-Features
Set-Content -Path "C:\inetpub\wwwroot\Default.html" -Value "This is the server $($env:COMPUTERNAME)"
