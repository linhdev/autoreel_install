@echo off
REM Tat AutoReel. Du lieu trong ./data khong bi dong toi.
setlocal
cd /d "%~dp0"
docker compose down
endlocal
