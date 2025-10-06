@echo off
setlocal

:: ===============================
:: CONFIGURATION
:: ===============================
set "REPO_URL=https://github.com/AlbertjanPieffers/Eklund_Engineering_Notenmachine.git"
set "BRANCH=main"

echo.
echo ==========================================
echo   GITHUB REPOSITORY SYNC TOOL
echo   Repository: %REPO_URL%
echo ==========================================
echo.

:: Ask for the local folder if not provided
set "TARGET_FOLDER=%~1"
if "%TARGET_FOLDER%"=="" (
    set /p TARGET_FOLDER="Enter local folder path for the repo: "
)

:: Move to the target folder
if not exist "%TARGET_FOLDER%" (
    echo [ERROR] The specified folder does not exist.
    pause
    exit /b 1
)

cd /d "%TARGET_FOLDER%"
echo Working directory: %cd%
echo.

:: ===============================
:: INITIALIZE OR UPDATE REPOSITORY
:: ===============================
if exist ".git" (
    echo [INFO] Existing Git repository detected.
) else (
    echo [INFO] No Git repository found. Initializing new one...
    git init
)

:: Set remote (always reset to ensure correctness)
git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%

:: ===============================
:: STAGE, COMMIT AND PUSH CHANGES
:: ===============================
echo.
set /p COMMIT_MSG="Enter commit message (default: Auto commit): "
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Auto commit"

echo.
echo [INFO] Staging all changes...
git add -A

echo [INFO] Creating commit: "%COMMIT_MSG%"
git commit -m "%COMMIT_MSG%" 2>nul

echo [INFO] Pushing to remote (%BRANCH%)...
git branch -M %BRANCH%
git push -u origin %BRANCH%

echo.
echo ==========================================
echo   DONE! Repository synced successfully.
echo ==========================================
pause
endlocal
