# ================================
# Configuración
# ================================

$outputFile = "hashes_detected.txt"

$extensions = @(
    "*.txt","*.config","*.xml","*.json","*.ini",
    "*.log","*.env","*.yml","*.yaml","*.cs"
)

# Patrones avanzados
$patterns = @(

    # Unix crypt
    "\$1\$[A-Za-z0-9./]+\$[A-Za-z0-9./]+",   # MD5 crypt
    "\$5\$[A-Za-z0-9./]+\$[A-Za-z0-9./]+",   # SHA256 crypt
    "\$6\$[A-Za-z0-9./]+\$[A-Za-z0-9./]+",   # SHA512 crypt

    # bcrypt
    "\$2[aby]?\$[0-9]{2}\$[A-Za-z0-9./]{53}",

    # NTLM (32 hex)
    "\b[A-Fa-f0-9]{32}\b",

    # SHA1
    "\b[A-Fa-f0-9]{40}\b",

    # SHA256
    "\b[A-Fa-f0-9]{64}\b",

    # Base64 largo (posible secreto)
    "\b[A-Za-z0-9+/]{20,}={0,2}\b",

    # JWT tokens
    "eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+"
)

# Exclusión de binarios
$excludeExtensions = @("*.dll","*.exe","*.png","*.jpg","*.jpeg","*.gif","*.zip","*.rar")

# Reset archivo salida
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

Write-Host "[+] Buscando hashes y secretos..." -ForegroundColor Cyan

# Evitar duplicados
$found = @{}

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

            foreach ($match in $matches) {

                $value = $match.Matches.Value

                # Filtro básico anti ruido (muy importante)
                if ($value.Length -lt 20) {
                    continue
                }

                if (-not $found.ContainsKey($value)) {

                    $found[$value] = $filePath

                    $line = "[+] Encontrado:"
                    $line2 = "    Archivo: $filePath"
                    $line3 = "    Tipo (#heurístico): $pattern"
                    $line4 = "    Valor: $value"
                    $line5 = ""

                    $line  | Out-File $outputFile -Append
                    $line2 | Out-File $outputFile -Append
                    $line3 | Out-File $outputFile -Append
                    $line4 | Out-File $outputFile -Append
                    $line5 | Out-File $outputFile -Append

                    Write-Host "[!] Match en $filePath" -ForegroundColor Yellow
                }
            }
        }

    } catch {
        # ignora errores de lectura
    }
}

Write-Host "`n[+] Total encontrados únicos: $($found.Count)" -ForegroundColor Green
Write-Host "[+] Resultado guardado en: $outputFile"
 