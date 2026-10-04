#!/usr/bin/env bash
# Kiểm tra credential đang lưu cho ghcr.io có quyền **ghi** package không.
#
#     ./check-ghcr-push.sh            # mặc định linhdev/shortgpt
#     ./check-ghcr-push.sh <owner> <package>
#
# Một token thiếu `write:packages` làm `docker push` thất bại với đúng một
# dòng:
#
#     error from registry: permission_denied: The token provided does not
#     match expected scopes.
#
# - và nó chỉ hiện ra sau khi đã build xong hai image. Câu hỏi ở đây mất hai
# giây, và trả lời cùng câu đó bằng một phép thử trực tiếp với registry:
# xin một token mang quyền đẩy, rồi thử mở một phiên upload. Registry từ chối
# quyền thì từ chối ngay tại đây; cho phép thì phiên upload đó tự hết hạn và
# không tạo ra gì.
#
# Không in ra token hay mật khẩu - chỉ in kết quả.
set -u

OWNER="${1:-${GHCR_OWNER:-linhdev}}"
PACKAGE="${2:-shortgpt}"

if [ ! -f "$HOME/.docker/config.json" ]; then
    echo "Chưa có ~/.docker/config.json - chưa đăng nhập Docker lần nào?"
    exit 2
fi

# Which credential helper holds it. Docker Desktop uses `desktop`; a plain
# Docker Engine on Linux usually uses `pass` or `secretservice`. Read from the
# config rather than assumed, because the wrong helper answers "credentials
# not found" for a machine that has them.
store="$(sed -n 's/.*"credsStore"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
         "$HOME/.docker/config.json" | head -1)"
store="${store:-desktop}"
helper="docker-credential-$store"

if ! command -v "$helper" >/dev/null 2>&1; then
    echo "Không thấy $helper - bỏ qua kiểm tra (đăng nhập rồi thì cứ chạy publish-images.sh)."
    exit 0
fi

cred="$(printf 'ghcr.io' | "$helper" get 2>/dev/null || true)"
username="$(printf '%s' "$cred" | sed -n 's/.*"Username":"\([^"]*\)".*/\1/p')"
secret="$(printf '%s' "$cred" | sed -n 's/.*"Secret":"\([^"]*\)".*/\1/p')"

if [ -z "$secret" ]; then
    echo "Chưa đăng nhập ghcr.io. Chạy:  docker login ghcr.io -u $OWNER"
    exit 2
fi

echo "Tài khoản đang lưu cho ghcr.io: $username"
if [ "$username" != "$OWNER" ]; then
    echo "  ! Khác với namespace sẽ đẩy tới ($OWNER). Token của tài khoản khác"
    echo "    không đẩy được vào namespace này - hoặc dùng GHCR_OWNER=$username,"
    echo "    hoặc đăng nhập bằng tài khoản $OWNER."
fi

token="$(curl -s -u "$username:$secret" \
         "https://ghcr.io/token?service=ghcr.io&scope=repository:$OWNER/$PACKAGE:push,pull" \
         | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
unset secret cred

if [ -z "$token" ]; then
    echo "x Không xin được token từ ghcr - credential sai, hoặc mạng không tới được ghcr.io."
    exit 2
fi

answer="$(curl -s -w '\n%{http_code}' -X POST \
          -H "Authorization: Bearer $token" \
          "https://ghcr.io/v2/$OWNER/$PACKAGE/blobs/uploads/")"
unset token
code="$(printf '%s' "$answer" | tail -1)"
body="$(printf '%s' "$answer" | head -c 300)"

case "$code" in
    202)
        echo "OK: token có quyền ghi vào $OWNER/$PACKAGE. Đẩy được."
        exit 0 ;;
    401|403)
        echo "x THIẾU QUYỀN GHI vào $OWNER/$PACKAGE (HTTP $code)."
        echo "  Registry trả lời: $body"
        echo
        echo "  Token classic (ghp_...) phải tick ô **write:packages** - chỉ tick"
        echo "  read:packages là ra đúng lỗi này. Token fine-grained thì cần"
        echo "  Account permissions -> Packages -> Read and write."
        echo "  Sau đó:  docker logout ghcr.io  &&  docker login ghcr.io -u $OWNER"
        echo "  (logout trước, để chắc chắn Docker không giữ token cũ.)"
        exit 1 ;;
    *)
        echo "? Trả lời lạ từ registry (HTTP $code): $body"
        exit 1 ;;
esac
