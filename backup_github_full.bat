@echo off
REM Backup NaxuGest Flutter vers GitHub (version complète)
cd /d "%~dp0"

echo 🟢 Pull des derniers changements depuis GitHub...
git pull origin main

echo 🟢 Vérification des changements locaux...
git status --porcelain > git_status.txt
setlocal enabledelayedexpansion
set HASCHANGES=0
for /f "delims=" %%a in (git_status.txt) do (
    set HASCHANGES=1
    echo ⚡ %%a
)
del git_status.txt

if !HASCHANGES! == 0 (
    echo ✅ Aucun changement local à committer.
    pause
    exit /b
)

echo 🟢 Ajout des fichiers modifiés...
git add .

echo 🟢 Commit avec message horodaté...
for /f "tokens=1-6 delims=/: " %%a in ("%date% %time%") do (
    set DATETIME=%%c-%%b-%%a_%%d-%%e
)
git commit -m "Sauvegarde NaxuGest %DATETIME%"

echo 🟢 Poussée sur GitHub...
git push origin main

echo ✅ Sauvegarde terminée !
pause
