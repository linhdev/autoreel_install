#!/usr/bin/env bash
# Build the two images and push them to ghcr - **for both chip families**.
#
#     ./publish-images.sh 2026-10-04                 # linux/amd64 + linux/arm64
#     ./publish-images.sh 2026-10-04 --amd64-only    # bỏ arm64
#
# **This one is for the machine that develops ShortGPT, not for the customer.**
# A customer machine never runs it - it only pulls what this pushed.
#
# Where the checkout is comes from SHORTGPT_REPO, or from a sibling folder
# named `ShortGPT` next to this one:
#
#     SHORTGPT_REPO=C:/work/ShortGPT ./publish-images.sh 2026-10-04
#
# Why two architectures in one tag: `docker pull` on the customer's machine
# asks the registry for *its* architecture, and a manifest list is what lets
# one tag answer both. An Apple Silicon Mac that gets the amd64 image still
# runs - under emulation - and everything slow (whisper, the renderer) becomes
# several times slower, which is a support call rather than a bug.
#
# The arm64 half is built on this machine under QEMU, so it is the slow part:
# tens of minutes rather than minutes, which is what `--amd64-only` is for.
#
# Two images, because the install folder runs both and neither is on Docker
# Hub:
#
#   ghcr.io/linhdev/shortgpt:<tag>            the app
#   ghcr.io/linhdev/moneyprinterturbo:<tag>   the renderer, with its source
#                                             baked in (the development
#                                             compose mounts that source
#                                             instead, which is why the plain
#                                             `mpt/Dockerfile` is not enough)
#
# The tag is also written as `latest` - so a customer who never sets
# SHORTGPT_IMAGE gets the newest one, and a customer who pins a date stays on
# it. Both are deliberate.
#
# Pushing needs an account with `write:packages` on the ghcr namespace:
#
#     docker login ghcr.io -u <github-user>     # password: a PAT
#
# After the first push, the packages are **private** by default. Make them
# public in the GitHub package settings, or every customer machine needs a
# token of its own - which is not something to hand out.

set -eu

TAG="${1:-}"
PLATFORMS=linux/amd64,linux/arm64
for argument in "$@"; do
    case "$argument" in
        --amd64-only) PLATFORMS=linux/amd64 ;;
    esac
done
if [ -z "$TAG" ] || [ "$TAG" = "--amd64-only" ]; then
    echo "Cần một tag: ./publish-images.sh 2026-10-04 [--amd64-only]" >&2
    exit 2
fi

OWNER="${GHCR_OWNER:-linhdev}"
REPO="${SHORTGPT_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../ShortGPT" 2>/dev/null && pwd || true)}"
[ -d "$REPO" ] || { echo "Không thấy kho mã nguồn. Đặt SHORTGPT_REPO=<đường dẫn>." >&2; exit 2; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths handed to docker are spelled the way docker spells them. On Windows
# that is `C:/...`, not the shell's `/c/...`: `docker` there is docker.exe, and
# whether the shell rewrites the path on the way out depends on how this was
# invoked (MSYS_NO_PATHCONV). Measured 2026-10-04: running it set, the build
# stopped at once with
#
#   unable to prepare context: path "/c/Users/.../ShortGPT" not found
#
# which names neither the shell nor the variable.
host_path() {
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -w "$1"
    else
        printf '%s' "$1"
    fi
}

APP_IMAGE="ghcr.io/$OWNER/shortgpt"
MPT_IMAGE="ghcr.io/$OWNER/moneyprinterturbo"

# Before either build, not after both. A token without `write:packages` fails
# the push with one line, and only once everything has been built - so the
# two-second question is worth asking first.
if [ -x "$HERE/check-ghcr-push.sh" ]; then
    "$HERE/check-ghcr-push.sh" "$OWNER" shortgpt || {
        echo "Dừng trước khi build: sửa quyền token rồi chạy lại (xem hướng dẫn ở trên)." >&2
        exit 1
    }
fi

# More than one platform needs a builder that is not the plain docker driver:
#
#   multiple platforms feature is currently not supported for docker driver
#
# Created here rather than assumed, so this works the same on a machine that
# has never built one. Deliberately *not* made the default builder - switching
# it would change how every other build on this machine behaves, and this
# script has no business doing that.
BUILDER="${BUILDX_BUILDER:-shortgpt-multiarch}"
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
    echo "==> Tạo builder cho build nhiều kiến trúc ($BUILDER)"
    docker buildx create --name "$BUILDER" --driver docker-container >/dev/null
fi
docker buildx inspect --bootstrap "$BUILDER" >/dev/null

echo "==> Kiến trúc: $PLATFORMS"

echo "==> Build + đẩy app image (shortgpt)"
# `--provenance=false` keeps the manifest list to the two real images. With it
# on, buildx adds an "unknown/unknown" attestation entry per platform, which
# older Docker clients in the field show as a third, unusable image.
docker buildx build \
    --builder "$BUILDER" \
    --platform "$PLATFORMS" \
    --provenance=false \
    --build-arg "TORCH_INDEX=${SHORTGPT_TORCH_INDEX:-https://download.pytorch.org/whl/cpu}" \
    -t "$APP_IMAGE:$TAG" \
    -t "$APP_IMAGE:latest" \
    --push "$(host_path "$REPO")"

echo "==> Build + đẩy renderer image (moneyprinterturbo, nhúng mã nguồn)"
# Generated from the same three lines the production compose carries inline
# (`docker-compose.prod.yml`, the two `dockerfile_inline:` blocks). Kept in
# step by hand because that file writes its Dockerfile inline on purpose - see
# the note at its top - and bake does not take an inline definition from the
# command line.
PROD_DOCKERFILE="$(mktemp -t mpt-prod-XXXXXX.Dockerfile)"
trap 'rm -f "$PROD_DOCKERFILE"' EXIT
cat > "$PROD_DOCKERFILE" <<'DOCKERFILE'
# The renderer's own published image - Python 3.11 and its whole dependency
# tree - plus the source, plus the one thing it has no provider for.
ARG MPT_BASE=ghcr.io/harry0703/moneyprinterturbo:latest
FROM ${MPT_BASE}
COPY . /MoneyPrinterTurbo
RUN pip install --no-cache-dir "zerotts>=0.1.5"
DOCKERFILE

docker buildx build \
    --builder "$BUILDER" \
    --platform "$PLATFORMS" \
    --provenance=false \
    --build-arg "MPT_BASE=${MPT_BASE:-ghcr.io/harry0703/moneyprinterturbo:latest}" \
    -f "$(host_path "$PROD_DOCKERFILE")" \
    -t "$MPT_IMAGE:$TAG" \
    -t "$MPT_IMAGE:latest" \
    --push "$(host_path "$REPO/vendor/moneyprinterturbo")"

cat <<EOF

Xong. Đã đẩy cho: $PLATFORMS

Máy khách hàng chạy:

    docker compose pull && docker compose up -d

Muốn ghim đúng bản này thì điền vào .env ở máy khách:

    SHORTGPT_IMAGE=$APP_IMAGE:$TAG
    MPT_IMAGE=$MPT_IMAGE:$TAG

Nhớ đổi hai package sang public (GitHub -> Packages -> Package settings ->
Change visibility), nếu không mỗi máy khách phải docker login.
EOF
