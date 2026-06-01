# ================================================================
# Offscene Mechanic Work Order - Windows EXE Builder
# Compatible with PowerShell 5+ and 7+
# ================================================================

$AppName   = "OffsceneMechanic"
$AppVersion = "1.0.0"
$MainClass = "MechanicWorkOrder"
$JarFile   = "MechanicWorkOrder.jar"
$IconFile  = "OffsceneLogo.ico"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "  Offscene Mechanic - EXE Builder" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow
Write-Host ""

# --- Find jpackage (PS5-compatible, no ?. operator) ---
$jpackage = $null

$cmd = Get-Command jpackage -ErrorAction SilentlyContinue
if ($cmd) { $jpackage = $cmd.Source }

if (-not $jpackage -and $env:JAVA_HOME) {
    $p = "$env:JAVA_HOME\bin\jpackage.exe"
    if (Test-Path $p) { $jpackage = $p }
}

$searchRoots = @(
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Microsoft",
    "C:\Program Files\Java",
    "C:\Program Files\BellSoft",
    "C:\Program Files\Amazon Corretto"
)
foreach ($root in $searchRoots) {
    if (-not $jpackage -and (Test-Path $root)) {
        $found = Get-ChildItem $root -Recurse -Filter jpackage.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $jpackage = $found.FullName }
    }
}

if (-not $jpackage) {
    Write-Host "ERROR: Could not find jpackage.exe" -ForegroundColor Red
    Write-Host "Please install a Java 17+ JDK from: https://adoptium.net" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found jpackage: $jpackage" -ForegroundColor Green
Write-Host ""

# --- Prepare directories ---
$inputDir  = "$ScriptDir\input"
$outputDir = "$ScriptDir\dist"
New-Item -ItemType Directory -Force -Path $inputDir  | Out-Null
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Copy-Item "$ScriptDir\$JarFile" "$inputDir\" -Force
if (Test-Path "$ScriptDir\offscene_logo.png") {
    Copy-Item "$ScriptDir\offscene_logo.png" "$inputDir\" -Force
}

# --- Build as app-image (no WiX needed) ---
Write-Host "Building app-image EXE (no WiX required)..." -ForegroundColor Cyan
Write-Host "This takes about 30-60 seconds..." -ForegroundColor Cyan
Write-Host ""

$args = @(
    "--type", "app-image",
    "--input", $inputDir,
    "--name", $AppName,
    "--main-jar", $JarFile,
    "--main-class", $MainClass,
    "--app-version", $AppVersion,
    "--description", "Offscene Mechanic Work Order System",
    "--vendor", "Offscene",
    "--dest", $outputDir,
    "--java-options", "-Dawt.useSystemAAFontSettings=on",
    "--java-options", "-Dswing.aatext=true"
)

if (Test-Path "$ScriptDir\$IconFile") {
    $args += "--icon"
    $args += "$ScriptDir\$IconFile"
}

& $jpackage @args

if ($LASTEXITCODE -eq 0) {
    $exePath = "$outputDir\$AppName\$AppName.exe"
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "  Your EXE is at:" -ForegroundColor Green
    Write-Host "  $exePath" -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can copy the entire '$AppName' folder anywhere." -ForegroundColor Cyan
    Write-Host "Run $AppName.exe inside it — no CMD, no warnings." -ForegroundColor Cyan
    Write-Host ""
    Start-Process explorer.exe "$outputDir\$AppName"
} else {
    Write-Host ""
    Write-Host "Build failed. Check the error above." -ForegroundColor Red
}

Read-Host "Press Enter to exit"
