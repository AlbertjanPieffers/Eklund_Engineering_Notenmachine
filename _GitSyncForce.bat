@echo off
setlocal

set "REPO_URL=https://github.com/AlbertjanPieffers/Eklund_Engineering_Notenmachine.git"
set "BRANCH=main"

set "TARGET_FOLDER=%~1"
if "%TARGET_FOLDER%"=="" (
  set /p TARGET_FOLDER="Enter local folder path: "
)
if not exist "%TARGET_FOLDER%" (
  echo [ERROR] Folder does not exist: "%TARGET_FOLDER%"
  exit /b 1
)
cd /d "%TARGET_FOLDER%"

git --version >nul 2>&1 || (echo [ERROR] Git not found in PATH.& exit /b 1)

if not exist ".git" (
  echo [INFO] Initializing new repository...
  git init || exit /b 1
)

git branch -M %BRANCH%
git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%

set /p COMMIT_MSG="Enter commit message (default: Force overwrite push): "
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Force overwrite push"

git add -A
git diff --cached --quiet || git commit -m "%COMMIT_MSG%"

echo [WARN] This will overwrite the remote branch '%BRANCH%' on GitHub.
choice /M "Continue with FORCE PUSH" /C YN
if errorlevel 2 (
  echo Aborted.
  exit /b 1
)

git push -u -f origin %BRANCH%
if errorlevel 1 (
  echo [ERROR] Force push failed.
  exit /b 1
)

echo [OK] Remote overwritten successfully.
exit /b 0
