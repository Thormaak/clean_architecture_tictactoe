# Script de validation de l'architecture Clean Architecture pour Claude Code
# Ce script s'execute apres chaque Write/Edit et verifie les imports interdits

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

# Ne verifier que les fichiers Dart dans lib/features/
if ($filePath -notmatch '^flutter_app/lib/features/.*\.dart$') {
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

$violations = @()

# ============================================
# DOMAIN LAYER - Ne doit rien importer d'externe
# ============================================
if ($filePath -match '/domain/') {
    # Flutter interdit (sauf foundation)
    if ($content -match "import\s+'package:flutter/(?!foundation)") {
        $violations += "DOMAIN: Import Flutter interdit (seul foundation.dart est autorise)"
    }

    # Firebase interdit
    if ($content -match "import\s+'package:(cloud_firestore|firebase_)") {
        $violations += "DOMAIN: Import Firebase interdit dans Domain"
    }

    # Packages HTTP interdits
    if ($content -match "import\s+'package:(dio|http)/") {
        $violations += "DOMAIN: Import HTTP (dio/http) interdit dans Domain"
    }

    # Infrastructure interdit
    if ($content -match "import\s+'.*infrastructure") {
        $violations += "DOMAIN: Import depuis Infrastructure interdit"
    }

    # Presentation interdit
    if ($content -match "import\s+'.*presentation") {
        $violations += "DOMAIN: Import depuis Presentation interdit"
    }

    # Application interdit (domain ne connait pas application)
    if ($content -match "import\s+'.*application") {
        $violations += "DOMAIN: Import depuis Application interdit"
    }

    # fromJson/toJson dans entity (indicateur de .g.dart)
    if ($content -match "part\s+'.*\.g\.dart'") {
        $violations += "DOMAIN: Les Entities ne doivent pas avoir de serialisation JSON (.g.dart)"
    }
}

# ============================================
# APPLICATION LAYER - Importe seulement Domain
# ============================================
if ($filePath -match '/application/') {
    # Infrastructure interdit
    if ($content -match "import\s+'.*infrastructure") {
        $violations += "APPLICATION: Import depuis Infrastructure interdit"
    }

    # Presentation interdit
    if ($content -match "import\s+'.*presentation") {
        $violations += "APPLICATION: Import depuis Presentation interdit"
    }

    # Flutter UI interdit (sauf foundation)
    if ($content -match "import\s+'package:flutter/(?!foundation)") {
        $violations += "APPLICATION: Import Flutter UI interdit (seul foundation.dart est autorise)"
    }
}

# ============================================
# INFRASTRUCTURE LAYER - Importe seulement Domain
# ============================================
if ($filePath -match '/infrastructure/') {
    # Application interdit
    if ($content -match "import\s+'.*application") {
        $violations += "INFRASTRUCTURE: Import depuis Application interdit"
    }

    # Presentation interdit
    if ($content -match "import\s+'.*presentation") {
        $violations += "INFRASTRUCTURE: Import depuis Presentation interdit"
    }
}

# ============================================
# PRESENTATION LAYER - Ne doit pas importer Infrastructure directement
# ============================================
if ($filePath -match '/presentation/') {
    # Infrastructure direct interdit (doit passer par DI)
    if ($content -match "import\s+'.*infrastructure/repositories/") {
        $violations += "PRESENTATION: Import direct de Repository Implementation interdit (utiliser DI)"
    }

    # Import de data_sources interdit
    if ($content -match "import\s+'.*infrastructure/data_sources/") {
        $violations += "PRESENTATION: Import de DataSource interdit (utiliser Repository)"
    }
}

# ============================================
# Afficher les violations
# ============================================
if ($violations.Count -gt 0) {
    Write-Output ""
    Write-Output "=========================================="
    Write-Output "ERREUR: Violation(s) Clean Architecture!"
    Write-Output "=========================================="
    Write-Output ""
    Write-Output "Fichier: $filePath"
    Write-Output ""
    foreach ($violation in $violations) {
        Write-Output "- $violation"
    }
    Write-Output ""
    Write-Output "Consultez .claude/rules/clean-architecture.md pour les regles."
    Write-Output ""
    exit 2
}

exit 0
