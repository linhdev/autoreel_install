#!/bin/bash
# Nhấp đôi file này để mở AutoReel.
#
# Cùng lý do như "Cài đặt.command": đây chỉ là cách thứ hai để mở AutoReel.app,
# dùng khi nhấp đôi thẳng vào app bị macOS chặn. Cách chính là nhấp phải vào
# AutoReel.app → Mở (lần đầu), sau đó nhấp đôi bình thường.

set -u

cd "$(dirname "$0")" || exit 1
xattr -dr com.apple.quarantine . 2>/dev/null

if [ ! -d "./AutoReel.app" ]; then
    echo "  Không thấy AutoReel.app cạnh file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

if ! touch .autoreel-write-test 2>/dev/null; then
    echo
    echo "  Thư mục này đang nằm trong file .dmg, chỉ đọc được."
    echo "  Kéo thư mục AutoReel ra Desktop (hoặc Applications) rồi chạy lại."
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi
rm -f .autoreel-write-test

open "./AutoReel.app"

echo
echo "  AutoReel đang mở. Cửa sổ này tự đóng."
