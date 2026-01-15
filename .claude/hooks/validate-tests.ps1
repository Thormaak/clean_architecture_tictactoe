# Script de validation des tests pour Claude Code (Monorepo)
# Ce script s'execute apres chaque Write/Edit et verifie qu'un test existe
# avec une qualite minimale

# Lire l'input du hook (JSON via variable d'environnement)
try {
    $toolInput = $env:TOOL_INPUT | ConvertFrom-Json
    $filePath = $toolInput.file_path
} catch {
    # Si pas d'input valide, ignorer
    exit 0
}

# Si pas de chemin de fichier, ignorer
if (-not $filePath) {
    exit 0
}

# Normaliser le chemin (convertir backslashes en forward slashes)
$filePath = $filePath -replace '\\', '/'

# Extraire le chemin relatif depuis la racine du projet si chemin absolu
if ($filePath -match 'tictactoe/(.*)') {
    $filePath = $matches[1]
}

# Exclure les fichiers generes (.g.dart, .freezed.dart)
if ($filePath -match '\.(g|freezed)\.dart$') {
    exit 0
}

# Exclure les fichiers de barrel (index.dart, exports)
if ($filePath -match '(index|exports?|providers)\.dart$') {
    exit 0
}

# ============================================
# FLUTTER APP - Regles de test
# ============================================

$flutterPatterns = @(
    'flutter_app/lib/.*/services/[^/]+\.dart$',
    'flutter_app/lib/.*/usecases/[^/]+\.dart$',
    'flutter_app/lib/.*/providers/[^/]+\.dart$',
    'flutter_app/lib/.*/cubit/[^/]+\.dart$',
    'flutter_app/lib/.*/notifiers/[^/]+\.dart$'
)

$isFlutterFile = $false
foreach ($pattern in $flutterPatterns) {
    if ($filePath -match $pattern) {
        $isFlutterFile = $true
        break
    }
}

if ($isFlutterFile) {
    # Construire le chemin du fichier test correspondant
    $testPath = $filePath -replace 'flutter_app/lib/', 'flutter_app/test/'
    $testPath = $testPath -replace '\.dart$', '_test.dart'

    # Verifier si le fichier test existe
    if (-not (Test-Path $testPath)) {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Test Flutter manquant!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier source: $filePath"
        Write-Output "Test attendu:   $testPath"
        Write-Output ""
        Write-Output "ACTION REQUISE:"
        Write-Output "Creez le fichier test avec au moins un test() utilisant mocktail."
        Write-Output "Consultez .claude/skills/flutter-test-generator/SKILL.md pour le template."
        Write-Output ""
        exit 2
    }

    # Verifier que le fichier test contient au moins un test
    $content = Get-Content $testPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Fichier test vide!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        Write-Output "ACTION REQUISE:"
        Write-Output "Ajoutez au moins un test() ou testWidgets() dans le fichier."
        Write-Output ""
        exit 2
    }

    # Verifier la presence d'au moins un test() ou testWidgets()
    if ($content -notmatch 'test\s*\(|testWidgets\s*\(') {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Aucun test trouve!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        Write-Output "Le fichier existe mais ne contient aucun test() ou testWidgets()."
        Write-Output ""
        Write-Output "ACTION REQUISE:"
        Write-Output "Ajoutez au moins un test avec le pattern Arrange/Act/Assert."
        Write-Output ""
        exit 2
    }

    # Verifier l'import de flutter_test
    if ($content -notmatch "import\s+'package:flutter_test/flutter_test\.dart'") {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Import flutter_test manquant!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        Write-Output "ACTION REQUISE:"
        Write-Output "Ajoutez: import 'package:flutter_test/flutter_test.dart';"
        Write-Output ""
        exit 2
    }

    # Verifier la presence d'un expect() (validation minimale)
    if ($content -notmatch 'expect\s*\(') {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ATTENTION: Aucun expect() trouve!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        Write-Output "Le test devrait contenir au moins un expect() pour valider le comportement."
        Write-Output ""
        Write-Output "Exemple:"
        Write-Output "  expect(result, expectedValue);"
        Write-Output "  expect(() => sut.method(), throwsException);"
        Write-Output ""
        # Warning seulement, ne bloque pas
        # exit 2
    }

    # Verifier l'utilisation de mocktail pour les fichiers avec dependances
    # (services, usecases qui ont probablement des dependances a mocker)
    if ($filePath -match '/(services|usecases)/' -and $content -notmatch "import\s+'package:mocktail/mocktail\.dart'") {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ATTENTION: mocktail non importe!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        Write-Output "Les tests de services/usecases devraient utiliser mocktail"
        Write-Output "pour mocker les dependances."
        Write-Output ""
        Write-Output "Ajoutez: import 'package:mocktail/mocktail.dart';"
        Write-Output ""
        # Warning seulement, ne bloque pas
        # exit 2
    }

    # Test Flutter OK
    exit 0
}

# ============================================
# FIREBASE BACKEND - Regles de test
# ============================================

$firebasePatterns = @(
    'backend/functions/src/[^/]+/[^/]+\.ts$'
)

$isFirebaseFile = $false
foreach ($pattern in $firebasePatterns) {
    if ($filePath -match $pattern) {
        # Exclure les fichiers de test eux-memes
        if ($filePath -notmatch '\.test\.ts$') {
            $isFirebaseFile = $true
        }
        break
    }
}

if ($isFirebaseFile) {
    # Construire le chemin du fichier test correspondant
    $testPath = $filePath -replace '\.ts$', '.test.ts'

    # Verifier si le fichier test existe
    if (-not (Test-Path $testPath)) {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Test Firebase manquant!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier source: $filePath"
        Write-Output "Test attendu:   $testPath"
        Write-Output ""
        Write-Output "ACTION REQUISE:"
        Write-Output "Creez le fichier test avec Jest."
        Write-Output "Consultez .claude/skills/firebase-test-generator/SKILL.md pour le template."
        Write-Output ""
        exit 2
    }

    # Verifier que le fichier test contient au moins un test
    $content = Get-Content $testPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Fichier test vide!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        exit 2
    }

    # Verifier la presence d'au moins un test (it ou test)
    if ($content -notmatch '(it|test)\s*\(') {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ERREUR: Aucun test trouve!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        Write-Output "Le fichier existe mais ne contient aucun it() ou test()."
        Write-Output ""
        exit 2
    }

    # Verifier la presence d'un expect()
    if ($content -notmatch 'expect\s*\(') {
        Write-Output ""
        Write-Output "=========================================="
        Write-Output "ATTENTION: Aucun expect() trouve!"
        Write-Output "=========================================="
        Write-Output ""
        Write-Output "Fichier: $testPath"
        Write-Output ""
        # Warning seulement
    }

    # Test Firebase OK
    exit 0
}

# Fichier non concerne par les regles de test
exit 0
