#!/usr/bin/env bash
# Mở cửa sổ Chrome để đăng nhập Shopee, kèm cổng gỡ lỗi cho app nối vào.
#
# Bản macOS của open-chrome.bat - cùng cổng, cùng hồ sơ, cùng lý do. Chạy:
#
#     ./open-chrome.sh
#
# App chạy trong container nên không tự mở được cửa sổ nào (trong đó không có
# màn hình). Cửa sổ mở ở đây, trên máy có màn hình, và app nối tới nó qua
# `host.docker.internal:47831` - Docker Desktop cho Mac chuyển tiếp được vào
# 127.0.0.1 của máy này.
#
# Không dùng 9222: đó là cổng mọi script chống gian lận thử đầu tiên.
#
# Hồ sơ là riêng: .chrome-shopee ngay cạnh file này. Trình duyệt bạn vẫn dùng
# hằng ngày không bị đụng tới, không phải đóng.
#
# Trong lúc cửa sổ này mở, ai vào được máy này thì điều khiển được nó - và nó
# đang đăng nhập Shopee. Dùng xong thì đóng lại.
set -u
cd "$(dirname "$0")" || exit 1

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME" ]; then
    echo "  Không thấy Google Chrome trong /Applications. Cài Chrome rồi chạy lại."
    echo "  (Hoặc sửa CHROME ở đầu file này nếu Chrome nằm chỗ khác.)"
    exit 1
fi

echo
echo "  Đang mở Chrome. Hãy đăng nhập Shopee trong cửa sổ vừa hiện ra."
echo "  Giữ cửa sổ đó mở trong lúc dùng app."
echo
"$CHROME" \
    --remote-debugging-port=47831 \
    --remote-debugging-address=0.0.0.0 \
    --remote-allow-origins='*' \
    --user-data-dir="$PWD/.chrome-shopee" \
    --no-first-run \
    --no-default-browser-check \
    --window-size=1200,900 \
    https://shopee.vn/ >/dev/null 2>&1 &
