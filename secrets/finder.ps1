# ================================
# Configuración
# ================================

$outputFile = "secrets_found.txt"

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

# Limpiar fichero anterior
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

"=== RESULTADOS DE BÚSQUEDA ===`n" | Out-File $outputFile -Encoding UTF8

Write-Host "[+] Buscando secretos..." -ForegroundColor Cyan

# ================================
# Búsqueda
# ================================

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

                    $line = "[!] Archivo: $filePath"
                    $line2 = "    Línea: $($match.LineNumber)"
                    $line3 = "    Match: $($match.Line.Trim())"
                    $line4 = ""

                    # Escribir en fichero
                    $line  | Out-File $outputFile -Append
                    $line2 | Out-File $outputFile -Append
                    $line3 | Out-File $outputFile -Append
                    $line4 | Out-File $outputFile -Append

                    # Mostrar en consola (opcional)
                    Write-Host "[!] $filePath : $($match.Line.Trim())" -ForegroundColor Red
                }
            }
        }

    } catch {
        # Ignorar errores de lectura
    }
}

Write-Host "`n[+] Resultados guardados en: $outputFile" -ForegroundColor Green