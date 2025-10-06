@echo off
setlocal

:: ================================
:: Simple commit & push (current dir)
:: ================================

:: Prevent common recursion pitfall: do not run if this file is named git.bat/cmd
set "SELF=%~nx0"
if /i "%SELF%"=="git.bat"  goto name_error
if /i "%SELF%"=="git.cmd"  goto name_error

:: Find real git.exe
set "GITEXE="
for /f "delims=" %%G in ('where git.exe 2^>nul') do (
    set "GITEXE=%%~fG"
    goto :found_git
)

:found_git
if not defined GITEXE (
    echo [ERROR] git.exe not found in PATH.
    echo Install Git for Windows and try again.
    exit /b 1
)

:: Ensure we are inside a Git repo
if not exist ".git" (
    echo [ERROR] No Git repository in this folder: %cd%
    echo Run "git init" and set the remote first.
    exit /b 1
)

:: Optional: show current branch
"%GITEXE%" rev-parse --abbrev-ref HEAD 1>nul 2>nul
if errorlevel 1 (
    echo [INFO] No commits yet. Creating initial empty commit anchor...
    "%GITEXE%" commit --allow-empty -m "Initial empty commit" 1>nul
)

:: Ask for commit message
set "MSG="
set /p MSG="Commit message (default: Auto commit): "
if "%MSG%"=="" set "MSG=Auto commit"

:: Stage + commit (only if there are staged changes)
"%GITEXE%" add -A
"%GITEXE%" diff --cached --quiet
if errorlevel 1 (
    "%GITEXE%" commit -m "%MSG%"
) else (
    echo [INFO] No changes to commit.
)

:: Push (set upstream if missing)
"%GITEXE%" rev-parse --abbrev-ref --symbolic-full-name @{u} 1>nul 2>nul
if errorlevel 1 (
    echo [INFO] No upstream set. Pushing to origin/main with -u...
    "%GITEXE%" push -u origin main
) else (
    "%GITEXE%" push
)

if errorlevel 1 (
    echo.
    echo [ERROR] Push failed.
    echo If the remote has commits you do not have locally, run:
    echo     git pull --rebase origin main
    echo and then run this script again.
    exit /b 1
)

echo [OK] Push successful.
exit /b 0

:name_error
echo [ERROR] Rename this file. Do NOT name it "git.bat" or "git.cmd".
exit /b 1
