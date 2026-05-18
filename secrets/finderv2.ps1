# ================================
# Configuración
# ================================

$outputFile = "interesting_files.txt"

$extensions = @(
    "*.txt","*.config","*.xml","*.json","*.ini",
    "*.log","*.env","*.yml","*.yaml","*.cs"
)

# Patrones más agresivos (BBDD + secretos)
$patterns = @(
    "password\s*[:=]",
    "pwd\s*[:=]",
    "user\s*id\s*=",
    "uid\s*=",
    "connectionstring",
    "server\s*=",
    "database\s*=",
    "data\s*source\s*=",
    "initial\s*catalog",
    "integrated\s*security",
    "persist\s*security\s*info",
    "mongodb://",
    "jdbc:",
    "redis://",
    "host\s*=",
    "port\s*=",
    "api[_-]?key",
    "secret",
    "token",
    "bearer",
    "AKIA[0-9A-Z]{16}",
    "BEGIN\s+PRIVATE\s+KEY"
)

# Excluir binarios
$excludeExtensions = @("*.dll","*.exe","*.png","*.jpg","*.jpeg","*.gif","*.zip","*.rar")

# Limpiar salida anterior
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

Write-Host "[+] Buscando archivos interesantes..." -ForegroundColor Cyan

# Set para evitar duplicados
$foundFiles = @{}

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
            $match = $content | Select-String -Pattern $pattern -SimpleMatch

            if ($match) {

                # Si no está ya registrado
                if (-not $foundFiles.ContainsKey($filePath)) {

                    $foundFiles[$filePath] = $pattern

                    $line = "[+] Archivo interesante: $filePath  | Pattern: $pattern"

                    # Log
                    $line | Out-File $outputFile -Append

                    # Consola
                    Write-Host $line -ForegroundColor Yellow
                }

                break
            }
        }

    } catch {
        # Ignorar errores
    }
}

Write-Host "`n[+] Total archivos interesantes: $($foundFiles.Count)" -ForegroundColor Green
Write-Host "[+] Resultado guardado en: $outputFile"