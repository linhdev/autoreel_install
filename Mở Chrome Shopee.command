#!/bin/bash
# Nhấp đôi file này để mở cửa sổ Chrome dành cho Shopee. Bản macOS của
# open-chrome.bat.
#
# Cửa sổ này dùng hồ sơ Chrome riêng (.chrome-shopee), nên trình duyệt bạn vẫn
# dùng hằng ngày không bị đụng tới và không phải đóng. Đăng nhập Shopee trong
# cửa sổ đó rồi **để nó mở** trong lúc dùng app.
#
# Mở xong thì cửa sổ Terminal này tự đóng - open-chrome.sh đẩy Chrome ra nền
# rồi thoát, và không có gì để đọc lại.

set -u

cd "$(dirname "$0")" || exit 1
xattr -dr com.apple.quarantine . 2>/dev/null

# Chạy từ trong .dmg chưa kéo ra? Hồ sơ Chrome (.chrome-shopee) phải ghi được
# xuống đĩa - xem giải thích đầy đủ ở "Cài đặt.command".
if ! touch .autoreel-write-test 2>/dev/null; then
    echo
    echo "  Thư mục này đang nằm trong file .dmg, chỉ đọc được."
    echo "  Kéo thư mục AutoReel ra Desktop (hoặc Applications) rồi chạy lại."
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi
rm -f .autoreel-write-test

if [ ! -f ./open-chrome.sh ]; then
    echo "  Không thấy open-chrome.sh cạnh file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

bash ./open-chrome.sh

# Chỉ giữ cửa sổ lại khi có lỗi. Thành công thì Chrome đã hiện ra rồi, và một
# cửa sổ Terminal nán lại chỉ làm khách bối rối không biết phải làm gì với nó.
if [ $? -ne 0 ]; then
    echo
    read -r -p "  Nhấn Enter để đóng cửa sổ này."
fi
