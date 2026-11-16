@echo off
rem Local test helper for this project (Dev Crew kit, playbook step 7). The work is done by local.ps1 next to this
rem file; this wrapper only starts it. Run "scripts\local.cmd help" for the commands.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0local.ps1" %*
exit /b %ERRORLEVEL%
