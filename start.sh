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
