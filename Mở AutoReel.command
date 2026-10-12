#!/bin/bash
# Nhấp đôi file này để mở AutoReel. Bản macOS của start.bat.
#
# Cùng ba việc mà mọi .command phải tự lo: đứng đúng thư mục, gỡ cờ cách ly, và
# giữ cửa sổ Terminal lại để đọc được dòng cuối. Giải thích đầy đủ ở đầu file
# "Cài đặt.command" - ở đây chỉ nhắc lại ngắn.

set -u

cd "$(dirname "$0")" || exit 1
xattr -dr com.apple.quarantine . 2>/dev/null

if [ ! -f ./start.sh ]; then
    echo "  Không thấy start.sh cạnh file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

bash ./start.sh
status=$?

echo
if [ "$status" -ne 0 ]; then
    echo "  Chưa mở được. Nếu đây là lần đầu, hãy chạy \"Cài đặt.command\" trước."
    echo
    read -r -p "  Nhấn Enter để đóng cửa sổ này."
fi
