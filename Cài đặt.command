#!/bin/bash
# Nhấp đôi file này để cài AutoReel.
#
# **Nó không cài gì cả - nó mở AutoReel.app.** Toàn bộ việc cài đặt nằm trong
# wizard của app: kiểm tra máy, cài Docker, kéo image, kích hoạt bản quyền. Việc
# của file này chỉ là một cách thứ hai để mở app, dùng khi nhấp đôi thẳng vào
# AutoReel.app bị macOS chặn.
#
# Trước đây file này chạy `install.sh` trong Terminal, và khách nhìn thấy toàn bộ
# quá trình dưới dạng chữ chạy. App có giao diện rồi thì đường đó chỉ còn là
# đường lui.
#
# Vẫn giữ hai thứ mà mọi .command cần:
#
#   1. Thư mục làm việc. Finder chạy .command với cwd là thư mục nhà, không phải
#      thư mục chứa file.
#   2. Gỡ cờ cách ly. Mọi thứ trong một .dmg vừa tải đều bị macOS gắn cờ, và
#      Gatekeeper chặn. Chính file này cũng bị chặn ở lần đầu - nên nó phải được
#      mở bằng **nhấp phải → Mở**, một lần duy nhất. Sau đó nó gỡ cờ cho cả thư
#      mục, và AutoReel.app lẫn những file còn lại chạy sạch.

set -u

cd "$(dirname "$0")" || {
    echo "  Không vào được thư mục chứa file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
}

xattr -dr com.apple.quarantine . 2>/dev/null

if [ ! -d "./AutoReel.app" ]; then
    echo
    echo "  Không thấy AutoReel.app cạnh file này."
    echo "  Có thể bạn đang chạy file từ trong file nén (.zip) - hãy kéo cả thư mục"
    echo "  ra Desktop hoặc Applications trước, rồi nhấp đôi lại."
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

# Ổ chỉ đọc? Chạy thẳng từ trong .dmg thì app không ghi được .env hay data/.
# Xem giải thích đầy đủ ở "Mở Chrome Shopee.command".
if ! touch .autoreel-write-test 2>/dev/null; then
    echo
    echo "  Thư mục này đang nằm trong file .dmg vừa mở, và ổ đó chỉ đọc được."
    echo
    echo "  Hãy làm thế này:"
    echo "    1. Kéo thư mục AutoReel ra Desktop (hoặc Applications)"
    echo "    2. Đóng cửa sổ .dmg lại"
    echo "    3. Nhấp đôi \"Cài đặt.command\" trong thư mục vừa kéo ra"
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi
rm -f .autoreel-write-test

# --first-run để app mở thẳng vào wizard, kể cả khi máy này đã cài xong một lần.
open "./AutoReel.app" --args --first-run

echo
echo "  AutoReel đang mở. Cửa sổ này tự đóng."
