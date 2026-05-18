$extensions = @(
    "*.txt","*.config","*.xml","*.json","*.ini",
    "*.log","*.env","*.yml","*.yaml","*.ps1","*.bat","*.cmd","*.cs"
)

$patterns = @(
    "password\s*[:=]\s*.+",
    "passwd\s*[:=]\s*.+",
    "pwd\s*[:=]\s*.+",
    "secret\s*[:=]\s*.+",
    "api[_-]?key\s*[:=]\s*.+",
    "token\s*[:=]\s*.+",
    "auth[_-]?token\s*[:=]\s*.+",
    "bearer\s+[A-Za-z0-9\-_\.]+",
    "connectionstring\s*[:=]\s*.+",
    "mongodb://.+",
    "Server=.*;Database=.*;User.*;Password=.*;",
    "AKIA[0-9A-Z]{16}", 
    "-----BEGIN PRIVATE KEY-----",
    "[A-Fa-f0-9]{32}", 
    "[A-Fa-f0-9]{64}"  
)

$excludeExtensions = @("*.dll","*.exe","*.png","*.jpg","*.jpeg","*.gif","*.zip","*.rar")

Write-Host "`n[+] Buscando secretos en $(Get-Location)...`n" -ForegroundColor Cyan

Get-ChildItem -Recurse -File -Include $extensions -ErrorAction SilentlyContinue |
Where-Object {
    $file = $_
    -not ($excludeExtensions | Where-Object { $file.Name -like $_ })
} |
ForEach-Object {

    $filePath = $_.FullName

    try {
        $content = Get-Content $filePath -ErrorAction Stop

        foreach ($pattern in $patterns) {
            $matches = $content | Select-String -Pattern $pattern -AllMatches

            if ($matches) {
                foreach ($match in $matches) {
                    Write-Host "[!] Posible secreto encontrado:" -ForegroundColor Red
                    Write-Host "    Archivo: $filePath"
                    Write-Host "    Línea: $($match.LineNumber)"
                    Write-Host "    Match: $($match.Line.Trim())`n"
                }
            }
        }

    } catch {
        
    }

}