@echo off
rem Starts a one-job GitHub Actions runner on this computer (Dev Crew kit, playbook step 9). The work is done by
rem gh-runner.ps1 next to this file.   scripts\gh-runner.cmd   take one job   |   scripts\gh-runner.cmd build
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gh-runner.ps1" %*
exit /b %ERRORLEVEL%
