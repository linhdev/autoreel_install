#!/bin/bash
# Nhấp đôi file này để cài AutoReel. Bản macOS của install.sh.
#
# Một file .command là một script chạy khi nhấp đôi trong Finder - macOS mở
# Terminal và chạy nó. Ba việc dưới đây là những thứ một script chạy kiểu đó
# phải tự lo, mà gọi thẳng install.sh thì không có:
#
#   1. Thư mục làm việc. Finder chạy .command với thư mục làm việc là thư mục
#      nhà, không phải thư mục chứa file. install.sh tự cd, nhưng nó cd theo
#      đường dẫn *tương đối của chính nó*, nên phải đứng đúng chỗ trước.
#
#   2. Cờ cách ly (quarantine). Mọi thứ trong một .dmg vừa tải về đều bị macOS
#      gắn cờ này, và Gatekeeper chặn không cho chạy. Chính file này cũng bị
#      chặn ở lần đầu - nên nó phải được mở bằng cách **nhấp phải → Mở**, một
#      lần duy nhất. Sau khi chạy được, nó gỡ cờ cho cả thư mục, và từ đó
#      install.sh cùng mọi file khác chạy sạch, không hỏi gì nữa.
#
#   3. Cửa sổ đóng mất. Terminal đóng ngay khi script kết thúc, nên bảng tổng
#      kết của install.sh - thứ duy nhất nói cho khách biết việc gì chưa xong -
#      sẽ loé lên rồi biến mất. Dòng `read` ở cuối giữ nó lại.

set -u

cd "$(dirname "$0")" || {
    echo "  Không vào được thư mục chứa file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
}

# Gỡ cờ cách ly cho cả thư mục. Không có gì để gỡ cũng không sao - chạy từ ổ
# USB hay từ thư mục đã tải lâu rồi thì lệnh này chỉ im lặng không làm gì.
xattr -dr com.apple.quarantine . 2>/dev/null

echo
echo "  AutoReel - cài đặt"
echo "  Thư mục: $PWD"
echo

if [ ! -f ./install.sh ]; then
    echo "  Không thấy install.sh cạnh file này."
    echo "  Có thể bạn đang chạy file từ trong file nén (.zip) - hãy kéo cả thư mục"
    echo "  ra Desktop hoặc Applications trước, rồi nhấp đôi lại."
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

bash ./install.sh
status=$?

echo
if [ "$status" -eq 0 ]; then
    echo "  Xong. Nhấp đôi \"Mở AutoReel.command\" để dùng."
else
    echo "  Cài đặt chưa hoàn tất - xem các dòng báo lỗi ở trên."
    echo "  Chạy lại file này sau khi sửa xong cũng được, không phải làm lại từ đầu."
fi
echo
read -r -p "  Nhấn Enter để đóng cửa sổ này."
