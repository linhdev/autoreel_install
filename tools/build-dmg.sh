#!/usr/bin/env bash
# Đóng thư mục này thành AutoReel.dmg để phát cho khách dùng Mac.
#
#     ./tools/build-dmg.sh 2026-10-12.2
#
# **Chỉ chạy được trên macOS.** `hdiutil` là công cụ duy nhất tạo ra được một
# file .dmg đúng chuẩn, và nó không có bản cho Windows hay Linux. Trên Windows
# thì dùng GitHub Actions - xem .github/workflows/build-dmg.yml, nó chạy đúng
# script này trên một máy Mac thật.
#
# Script này nằm trong kho mã nguồn chứ không phải thứ phát cho khách, nên nó
# tự loại mình ra khỏi cái .dmg mà nó tạo (xem DANH SÁCH LOẠI TRỪ bên dưới).
#
# Cái .dmg chứa **thư mục**, không phải một ứng dụng .app. Khách mở ra, thấy
# thư mục AutoReel với ba file .command nhấp đôi được. Đó không phải cách đóng
# gói quen thuộc của Mac (kéo vào Applications), nhưng nó là cách trung thực:
# app này chạy bằng Docker, không có gì để "cài vào Applications" cả.

set -eu

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$HERE"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Cần một version: ./tools/build-dmg.sh 2026-10-12.2" >&2
    exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
    echo "LỖI: không có hdiutil - script này chỉ chạy trên macOS." >&2
    echo "      Trên Windows dùng GitHub Actions: .github/workflows/build-dmg.yml" >&2
    exit 1
fi

OUT="$HERE/dist"
# Hai tầng, và tầng thừa ra là cố ý.
#
# `hdiutil create -srcfolder X` chép **nội dung của X** ra gốc ổ đĩa, không chép
# chính X. Nên đưa thẳng thư mục khách hàng vào đó thì khách mở .dmg ra sẽ thấy
# install.sh, docker-compose.yml, ba file .command... nằm trần trụi ở gốc, và
# không có thư mục "AutoReel" nào để kéo ra Desktop - trong khi README dạy đúng
# là kéo thư mục đó.
#
# Nên: dựng `pkg/AutoReel/`, rồi đưa `pkg` cho hdiutil. Gốc ổ đĩa nhận được
# đúng một thư mục tên AutoReel, và cái tên đó khớp với thứ README nói.
PKG="$OUT/pkg"
STAGE="$PKG/AutoReel"
DMG="$OUT/AutoReel-$VERSION.dmg"

# ------------------------------------------------------------ danh sách loại trừ
#
# Những thứ **không** được vào trong .dmg, và mỗi dòng có một lý do:
#
#   data/            dữ liệu chạy của máy này - video, database, model. Hàng GB,
#                    và là dữ liệu riêng của người đóng gói. Có vào đó là vừa
#                    nặng vừa rò rỉ.
#   .env             cấu hình thật của máy này, kèm key. Không bao giờ phát.
#   .chrome-shopee/  hồ sơ Chrome đã đăng nhập Shopee.
#   tools/           chính script này, và những thứ chỉ có nghĩa trên máy phát
#                    triển. Khách không có việc gì với chúng.
#   .github/         như trên.
#   .git/            lịch sử của kho mã nguồn.
#   dist/            đầu ra của lần đóng gói trước - nếu không loại ra thì mỗi
#                    lần build lại nhét cái .dmg cũ vào trong cái .dmg mới.
#   logs/            log của trình quản lý, sinh ra khi app chạy. Trên máy đóng
#                    gói thì đây là dấu vết của chính lượt thử nghiệm vừa rồi -
#                    và nó đã lọt vào một bản .dmg một lần, mang theo đường dẫn
#                    thư mục của máy build.
#   *.zip            file nén tải về, không phải nội dung.
EXCLUDES=(
    --exclude "data"
    --exclude ".env"
    --exclude ".chrome-shopee"
    --exclude "tools"
    --exclude ".github"
    --exclude ".git"
    --exclude "dist"
    --exclude "logs"
    --exclude ".DS_Store"
)

echo "==> Dọn đầu ra cũ"
rm -rf "$PKG" "$DMG"
mkdir -p "$STAGE"

echo "==> Chép nội dung thư mục khách hàng"
# rsync chứ không cp: nó nhận danh sách loại trừ, và nó giữ quyền chạy của file
# - điều mà cả .command lẫn install.sh đều cần.
rsync -a "${EXCLUDES[@]}" --exclude "*.zip" ./ "$STAGE/"

# Quyền chạy, đặt lại lần nữa cho chắc.
#
# Chúng đã đúng trong git (chế độ 100755 được lưu trong kho), nhưng một bản
# checkout sai cấu hình - hoặc một lần chép tay qua Windows - có thể làm mất
# bit đó, và triệu chứng là "The file could not be executed" khi khách nhấp
# đôi. Đặt lại ở đây thì không phải đoán.
chmod +x "$STAGE"/*.sh "$STAGE"/*.command 2>/dev/null || true

echo "==> Kiểm tra những gì sắp đóng gói"
missing=0
# AutoReel.app là thứ khách thật sự chạy. Thiếu nó thì phần còn lại chỉ là một
# thư mục script - đúng thứ bộ cài này được viết ra để thay thế. Từ chối đóng,
# vì một .dmg như vậy vẫn tải về được và vẫn mở được, và không ai biết là sai
# cho tới khi khách hỏi tại sao không có giao diện.
for required in "AutoReel.app" install.sh start.sh docker-compose.yml "Cài đặt.command"; do
    if [ ! -e "$STAGE/$required" ]; then
        echo "    THIẾU: $required"
        missing=$((missing + 1))
    fi
done
if [ "$missing" -gt 0 ]; then
    echo "LỖI: thiếu $missing file bắt buộc - .dmg sẽ không dùng được." >&2
    exit 1
fi
if [ -e "$STAGE/.env" ] || [ -d "$STAGE/data" ] || [ -d "$STAGE/logs" ]; then
    echo "LỖI: .env, data/ hoặc logs/ lọt vào bản đóng gói. Dừng lại." >&2
    exit 1
fi
echo "    OK - $(find "$STAGE" -type f | wc -l | tr -d ' ') file, $(du -sh "$STAGE" | cut -f1)"

echo "==> Tạo .dmg"
# UDZO = nén, chỉ đọc. Đúng cho một thứ để tải về.
# -volname là tên hiện ra trên Desktop khi khách mở file.
hdiutil create \
    -volname "AutoReel" \
    -srcfolder "$PKG" \
    -ov \
    -format UDZO \
    "$DMG" >/dev/null

rm -rf "$PKG"

SIZE="$(du -h "$DMG" | cut -f1)"
HASH="$(shasum -a 256 "$DMG" | cut -d' ' -f1)"

echo
echo "  $DMG"
echo "  $SIZE   SHA256 $HASH"
echo
echo "  Đăng kèm release trên linhdev/autoreel-releases:"
echo "    gh release upload $VERSION \"$DMG\" --repo linhdev/autoreel-releases"
echo
