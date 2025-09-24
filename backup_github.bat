@echo off
REM Backup NaxuGest Flutter vers GitHub
cd /d "%~dp0"

echo 🟢 Ajout des fichiers...
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
