@echo off
REM Backup NaxuGest Flutter vers GitHub (version sécurisée)
cd /d "%~dp0"

echo 🟢 Vérification des changements...
git status --porcelain > git_status.txt
set /p HASCHANGES=<git_status.txt
del git_status.txt

if "%HASCHANGES%"=="" (
    echo ⚠️ Aucun changement détecté. Pas de commit nécessaire.
    pause
    exit /b
)

echo 🟢 Changements détectés. Ajout des fichiers...
git add .

echo 🟢 Commit avec message horodaté...
for /f "tokens=1-6 delims=/: " %%a in ("%date% %time%") do (
    set DATETIME=%%c-%%b-%%a_%%d-%%e
)
git commit -m "Sauvegarde NaxuGest %DATETIME%"

echo 🟢 Poussée sur GitHub...
git push

echo ✅ Sauvegarde terminée !
pause
