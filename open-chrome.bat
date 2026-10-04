@echo off
REM Mo cua so Chrome de dang nhap Shopee, kem cong go loi cho app noi vao.
REM
REM App chay trong container nen khong tu mo duoc cua so nao - trong do khong
REM co man hinh. Vi vay cua so duoc mo o day, tren may co man hinh, va app noi
REM toi no qua cong ben duoi (host.docker.internal:47831).
REM
REM Khong dung 9222. Do la cong ma moi script chong gian lan thu dau tien -
REM mot trang co the do duoc WebSocket toi do va biet cong mo hay dong. Khong
REM co gi hop phap dung 47831.
REM
REM Doi cong o day thi phai doi ca SHOPEE_CDP_PORT trong docker-compose.yml.
REM
REM --remote-debugging-address=0.0.0.0 khong phai tuy chon: thieu no thi Chrome
REM chi nghe tren 127.0.0.1 cua chinh may nay, va container ket noi vao se bi
REM tu choi. (Chrome 153 tro len bo qua co nay - app da co san mot "relay"
REM chay trong container de bu, xem shortGPT/integrations/shopee_tools.py.)
REM
REM Ho so (profile) la rieng: .chrome-shopee ngay canh file nay. Trinh duyet
REM ban dang dung khong bi dung toi, khong phai dong.
REM
REM Trong luc cua so nay mo, ai vao duoc may nay thi dieu khien duoc no - va no
REM dang dang nhap Shopee. Dung xong thi dong lai.
setlocal
cd /d "%~dp0"

set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" (
  echo   Khong thay Chrome. Cai Chrome roi chay lai file nay.
  pause
  exit /b 1
)

echo.
echo   Dang mo Chrome. Hay dang nhap Shopee trong cua so vua hien ra.
echo   Giu cua so do mo trong luc dung app.
echo.
start "" "%CHROME%" ^
  --remote-debugging-port=47831 ^
  --remote-debugging-address=0.0.0.0 ^
  --remote-allow-origins=* ^
  --user-data-dir="%CD%\.chrome-shopee" ^
  --no-first-run ^
  --no-default-browser-check ^
  --window-size=1200,900 ^
  https://shopee.vn/
endlocal
