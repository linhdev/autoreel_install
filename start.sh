#!/usr/bin/env bash
# Khởi động ShortGPT và mở giao diện. Bản macOS của start.bat.
#
# Chạy lại được nhiều lần: compose chỉ dựng lại những container còn thiếu.
# Lần đầu thì nên chạy ./install.sh trước (nó cài Docker, adb, Chrome).
set -u
cd "$(dirname "$0")" || exit 1

command -v docker >/dev/null 2>&1 || {
    echo "  Chưa có Docker. Chạy ./install.sh trước."
    exit 1
}

# Cổng ngoài: lấy từ .env nếu có, không thì 31415 - cùng giá trị mà
# docker-compose.yml dùng. Biến môi trường đứng trước, đúng như compose.
port="${SHORTGPT_PORT:-}"
if [ -z "$port" ] && [ -f .env ]; then
    port="$(grep -E '^SHORTGPT_PORT=' .env | head -1 | cut -d= -f2-)"
fi
port="${port:-31415}"

# Bản mới, nếu có. `docker compose up -d` một mình chỉ dùng image đã nằm sẵn
# trên máy, nên một bản cài đã tải image về sẽ giữ nguyên bản đó **mãi mãi** —
# bên bán đẩy bản mới lên cũng không tới được ai. Kiểm tra ở đây, mỗi lần khởi
# động, là cách duy nhất nó tự tới.
#
# Nhưng không được để nó chặn: khách mất mạng vẫn phải mở được app bằng bản
# đang có. Nên `pull` hỏng thì chỉ cảnh báo rồi đi tiếp, và nói rõ là đang
# chạy bản cũ.
echo "  Đang kiểm tra bản mới..."
if docker compose pull --quiet 2>/dev/null; then
    echo "  Đã có bản mới nhất."
else
    echo "  ! Không kiểm tra được bản mới (mất mạng?) - chạy bản đang có trên máy."
fi

echo "  Đang khởi động ShortGPT..."
docker compose up -d || {
    echo "  Không khởi động được. Xem:  docker compose logs --tail 50 shortgpt"
    exit 1
}

echo "  Đợi app sẵn sàng..."
waited=0
while [ "$waited" -lt 90 ]; do
    if curl -s -o /dev/null --max-time 3 "http://localhost:$port/"; then
        echo "  Xong. Đang mở http://localhost:$port"
        open "http://localhost:$port"
        exit 0
    fi
    sleep 3
    waited=$((waited + 3))
done

echo "  App chưa trả lời sau 90 giây. Xem:  docker compose logs --tail 50 shortgpt"
exit 1
