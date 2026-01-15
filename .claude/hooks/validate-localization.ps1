# Script de validation de la localisation pour Claude Code
# Ce script s'execute apres chaque Write/Edit et detecte les strings hardcodees

# Lire l'input du hook (JSON via variable d'environnement)
try {
    $toolInput = $env:TOOL_INPUT | ConvertFrom-Json
    $filePath = $toolInput.file_path
} catch {
    exit 0
}

if (-not $filePath) {
    exit 0
}

# Normaliser le chemin
$filePath = $filePath -replace '\\', '/'

# Extraire le chemin relatif
if ($filePath -match 'tictactoe/(.*)') {
    $filePath = $matches[1]
}

# Ne verifier que les fichiers Dart dans presentation/
if ($filePath -notmatch '^flutter_app/lib/features/.*/presentation/.*\.dart$') {
    exit 0
}

# Exclure les fichiers generes
if ($filePath -match '\.(g|freezed)\.dart$') {
    exit 0
}

# Lire le contenu du fichier
$fullPath = Join-Path (Get-Location) $filePath
if (-not (Test-Path $fullPath)) {
    exit 0
}

$content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
if (-not $content) {
    exit 0
}

$warnings = @()

# Patterns de strings potentiellement hardcodees
# On cherche les Text() avec des strings directes (pas des variables)

# Pattern: Text('...')  ou Text("...")
$textMatches = [regex]::Matches($content, "Text\s*\(\s*['""]([^'""]+)['""]")

foreach ($match in $textMatches) {
    $stringValue = $match.Groups[1].Value

    # Ignorer les patterns qui ne sont pas du texte utilisateur
    $ignore = $false

    # Ignorer les strings courtes (1-2 chars) qui sont probablement des symboles
    if ($stringValue.Length -le 2) { $ignore = $true }

    # Ignorer les patterns techniques
    if ($stringValue -match '^\$') { $ignore = $true }  # Variables interpolees
    if ($stringValue -match '^[0-9.]+$') { $ignore = $true }  # Nombres
    if ($stringValue -match '^[\s\-_/:.]+$') { $ignore = $true }  # Separateurs
    if ($stringValue -match '^(X|O|x|o)$') { $ignore = $true }  # Symboles de jeu

    if (-not $ignore) {
        # Verifier si c'est une phrase (contient des espaces et commence par majuscule)
        if ($stringValue -match '^[A-Z][a-z].*\s') {
            $warnings += "String hardcodee potentielle: '$stringValue'"
        }
    }
}

# Pattern: title: '...' ou label: '...'
$labelMatches = [regex]::Matches($content, "(title|label|hintText|errorText|helperText|message)\s*:\s*['""]([^'""]+)['""]")

foreach ($match in $labelMatches) {
    $propName = $match.Groups[1].Value
    $stringValue = $match.Groups[2].Value

    # Ignorer les strings courtes
    if ($stringValue.Length -gt 3 -and $stringValue -match '[A-Za-z]') {
        $warnings += "Propriete '$propName' avec string hardcodee: '$stringValue'"
    }
}

# ============================================
# Afficher les warnings (ne bloque pas, juste avertit)
# ============================================
if ($warnings.Count -gt 0) {
    Write-Output ""
    Write-Output "=========================================="
    Write-Output "ATTENTION: Strings potentiellement non localisees"
    Write-Output "=========================================="
    Write-Output ""
    Write-Output "Fichier: $filePath"
    Write-Output ""
    foreach ($warning in $warnings) {
        Write-Output "- $warning"
    }
    Write-Output ""
    Write-Output "Si ces strings sont destinees a l'utilisateur,"
    Write-Output "utilisez context.l10n.xxx au lieu de strings hardcodees."
    Write-Output ""
    Write-Output "Consultez .claude/rules/localization-patterns.md"
    Write-Output ""
    # Exit 0 = warning seulement, ne bloque pas
    # Changer en exit 2 pour bloquer
    exit 0
}

exit 0
