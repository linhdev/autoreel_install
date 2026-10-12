#!/bin/bash
# Nhấp đôi file này để cài AutoReel.
#
# Nó chạy `install.sh` - toàn bộ việc cài đặt nằm trong đó. Xem README.md để
# biết cách cài bằng Terminal, cách đó nhanh hơn và không bị macOS chặn.
#
# ## Vì sao đây không phải cách chính
#
# Một file .command là một file thực thi, nên macOS dán cờ cách ly lên nó y như
# lên một ứng dụng, và lần đầu nhấp đôi sẽ bị chặn. **Nhấp phải → Mở không còn
# tác dụng** từ macOS 15 - phải vào System Settings → Privacy & Security → bấm
# "Open Anyway", hoặc gỡ cờ bằng Terminal.
#
# Mà gỡ cờ bằng Terminal thì cũng mở Terminal rồi - nên gõ luôn `./install.sh`
# cho xong. File này chỉ có ích khi macOS chịu mở nó.
#
# Hai việc dưới đây vẫn cần, vì chúng là những thứ duy nhất file này làm được
# mà gọi thẳng install.sh thì không:
#
#   1. Thư mục làm việc. Finder chạy .command với cwd là thư mục nhà, không
#      phải thư mục chứa file.
#   2. Cửa sổ đóng mất. Terminal đóng ngay khi script xong, nên bảng tổng kết
#      của install.sh - thứ duy nhất nói việc gì chưa xong - sẽ loé lên rồi
#      biến mất. Dòng `read` ở cuối giữ nó lại.

set -u

cd "$(dirname "$0")" || {
    echo "  Không vào được thư mục chứa file này."
    read -r -p "  Nhấn Enter để đóng."
    exit 1
}

# Gỡ cờ cách ly cho cả thư mục. Không có gì để gỡ cũng không sao - chạy từ ổ USB
# hay từ thư mục đã tải lâu rồi thì lệnh này chỉ im lặng không làm gì.
xattr -dr com.apple.quarantine . 2>/dev/null

# Đang chạy từ **bên trong** file .dmg vừa mở?
#
# Đây là chỗ dễ sai nhất, và sai một cách rất khó hiểu. Một .dmg gắn vào là ổ
# chỉ đọc. Khách mở .dmg ra, thấy thư mục AutoReel, nhấp đôi luôn - macOS cho
# chạy, rồi install.sh chết ở bước đầu tiên vì không tạo được .env. Câu báo lỗi
# là "Read-only file system", nghe như hỏng đĩa chứ không như "bạn quên kéo
# thư mục ra".
#
# Cách phát hiện: thử ghi một file. Đơn giản hơn là đoán qua đường dẫn, và đúng
# cho mọi trường hợp chỉ đọc - .dmg, đĩa quang, ổ mạng gắn read-only.
if ! touch .autoreel-write-test 2>/dev/null; then
    echo
    echo "  Thư mục này đang nằm trong file .dmg vừa mở, và ổ đó chỉ đọc được."
    echo
    echo "  Hãy làm thế này:"
    echo "    1. Kéo thư mục AutoReel ra Desktop"
    echo "    2. Đóng cửa sổ .dmg lại"
    echo "    3. Mở Terminal, gõ  cd  (có dấu cách), kéo thư mục vào, Enter"
    echo "    4. Gõ  ./install.sh"
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi
rm -f .autoreel-write-test

if [ ! -f ./install.sh ]; then
    echo "  Không thấy install.sh cạnh file này."
    echo "  Có thể bạn đang chạy file từ trong file nén (.zip) - hãy kéo cả thư mục"
    echo "  ra Desktop trước, rồi nhấp đôi lại."
    echo
    read -r -p "  Nhấn Enter để đóng."
    exit 1
fi

bash ./install.sh
status=$?

echo
if [ "$status" -eq 0 ]; then
    echo "  Xong. Nhấp đôi \"Mở AutoReel.command\" để dùng,"
    echo "  hoặc mở http://localhost:31415"
else
    echo "  Cài đặt chưa hoàn tất - xem các dòng báo lỗi ở trên."
    echo "  Chạy lại file này sau khi sửa xong cũng được, không phải làm lại từ đầu."
fi
echo
read -r -p "  Nhấn Enter để đóng cửa sổ này."
