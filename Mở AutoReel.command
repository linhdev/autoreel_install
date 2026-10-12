#!/bin/bash
# Nhấp đôi file này để mở AutoReel.
#
# Nó chạy `start.sh`, cùng thứ mà `start.bat` chạy trên Windows: kiểm tra bản
# mới, khởi động container, đợi app trả lời, rồi mở trình duyệt.
#
# Xem đầu file "Cài đặt.command" để biết vì sao cách này không phải cách chính -
# tóm lại: macOS chặn file thực thi tải từ mạng, và gỡ chặn thì cũng phải mở
# Terminal rồi.

set -u

cd "$(dirname "$0")" || exit 1
xattr -dr com.apple.quarantine . 2>/dev/null

# Chạy từ trong .dmg chưa kéo ra? Ổ đó chỉ đọc, nên app không ghi được gì vào
# data/. Xem giải thích đầy đủ ở "Cài đặt.command".
if ! touch .autoreel-write-test 2>/dev/null; then
    echo
    echo "  Thư mục này đang nằm trong file .dmg, chỉ đọc được."
    echo "  Kéo thư mục AutoReel ra Desktop rồi chạy lại."
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi
rm -f .autoreel-write-test

if [ ! -f ./start.sh ]; then
    echo "  Không thấy start.sh cạnh file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

bash ./start.sh
status=$?

if [ "$status" -ne 0 ]; then
    echo
    echo "  Chưa mở được. Nếu đây là lần đầu, hãy chạy \"Cài đặt.command\" trước,"
    echo "  hoặc gõ ./install.sh trong Terminal."
    echo
    read -r -p "  Nhấn Enter để đóng cửa sổ này."
fi
