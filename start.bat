@echo off
REM Khoi dong ShortGPT va mo giao dien.
REM
REM Chay lai duoc nhieu lan: compose chi dung lai nhung container nao dang thieu.
REM Lan dau tien thi nen chay install.sh truoc (no cai Docker, adb, Chrome).
setlocal
cd /d "%~dp0"

where docker >nul 2>&1
if errorlevel 1 (
  echo   Chua co Docker. Chay install.sh trong Git Bash truoc.
  pause
  exit /b 1
)

REM Cong ngoai: lay tu .env neu co, khong thi 31415 - cung gia tri ma
REM docker-compose.yml dung.
set "PORT=31415"
if exist ".env" for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
  if /i "%%a"=="SHORTGPT_PORT" set "PORT=%%b"
)

echo   Dang khoi dong ShortGPT...
docker compose up -d
if errorlevel 1 (
  echo.
  echo   Khong khoi dong duoc. Xem log:  docker compose logs --tail 50 shortgpt
  pause
  exit /b 1
)

echo   Doi app san sang...
set /a tries=0
:wait
curl -s -o nul --max-time 3 http://localhost:%PORT%/ && goto ready
set /a tries+=1
if %tries% GEQ 30 (
  echo.
  echo   App chua tra loi sau 90 giay. Xem log:  docker compose logs --tail 50 shortgpt
  pause
  exit /b 1
)
timeout /t 3 /nobreak >nul
goto wait

:ready
echo   Xong. Dang mo http://localhost:%PORT%
start "" http://localhost:%PORT%
endlocal
