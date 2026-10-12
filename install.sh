#!/usr/bin/env bash
# Install ShortGPT on a Windows machine, from the images on ghcr.
#
# Run it from **Git Bash**, which comes with Git for Windows:
#
#     ./install.sh            # install or update
#     ./install.sh check      # look and report, change nothing
#
# It is written for a machine that has nothing yet: Docker Desktop, adb, a
# Chrome, the API keys, the folders - each one is checked, installed when it
# is missing, and reported at the end whether it worked. Running it twice is
# fine; every step asks "is this already here?" first.
#
# What it deliberately does NOT do: sign anybody in to Shopee, and pair a
# phone. Both need a person - see the last screen it prints.
#
# Every step ends in one of three states, and the summary at the end is the
# honest one: OK (done and verified), WARN (works, but something about it is
# for a person to finish) or FAIL (this part does not work yet, and here is
# the line to read). A WARN is not a failure - a fresh Docker Desktop that
# wants to be started by hand is a WARN.

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE" || exit 1

MODE="${1:-install}"
DO_INSTALL=1
[ "$MODE" = "check" ] && DO_INSTALL=0

# The API keys live in .env, which install.sh writes the first time and never
# overwrites. See write_env.
ENV_FILE="$HERE/.env"

RESULTS=()

# ------------------------------------------------------------------ printing

if [ -t 1 ]; then
    BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'
    GREEN=$'\033[32m'; YELLOW=$'\033[33m'; OFF=$'\033[0m'
else
    BOLD=''; DIM=''; RED=''; GREEN=''; YELLOW=''; OFF=''
fi

step()  { printf '\n%s==> %s%s\n' "$BOLD" "$1" "$OFF"; }
note()  { printf '    %s\n' "$1"; }
dim()   { printf '    %s%s%s\n' "$DIM" "$1" "$OFF"; }
ok()    { printf '    %s✓%s %s\n' "$GREEN" "$OFF" "$1"; RESULTS+=("OK|$1"); }
warn()  { printf '    %s!%s %s\n' "$YELLOW" "$OFF" "$1"; RESULTS+=("WARN|$1"); }
bad()   { printf '    %sx%s %s\n' "$RED" "$OFF" "$1"; RESULTS+=("FAIL|$1"); }
die()   { printf '\n%sLỖI: %s%s\n' "$RED" "$1" "$OFF"; exit 1; }

# --------------------------------------------------------------- environment

# Two machines are supported, and the whole script is written so that the
# differences sit in a handful of named functions: `PLATFORM` is `windows` or
# `mac`, and everything below that touches the host - a package manager, a
# browser path, a way to start Docker - asks which one it is.
#
# Git Bash reports itself as MINGW64_NT-10.0-26200 or MSYS_NT-*; macOS says
# Darwin and means it.
check_shell() {
    step "Kiểm tra môi trường"
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            PLATFORM=windows
            ok "Git Bash trên Windows" ;;
        Darwin)
            PLATFORM=mac
            ok "macOS ($(uname -m))" ;;
        *)
            die "Script này chạy trên Windows (Git Bash) hoặc macOS. Máy này là $(uname -s) - trên Linux thì dùng docker-compose.yml trực tiếp." ;;
    esac

    # The path of this folder *as the rest of the machine spells it*. The
    # Library screen shows it, so on Windows it has to be what Explorer
    # understands - `pwd -W` is the MSYS spelling of `C:/...` rather than
    # `/c/...`. macOS paths are already POSIX.
    if [ "$PLATFORM" = "windows" ]; then
        HOST_HERE="$(pwd -W 2>/dev/null || pwd)"
    else
        HOST_HERE="$HERE"
    fi
    dim "Thư mục cài đặt: $HOST_HERE"

    # Apple Silicon is not a detail here: the images are built for both
    # `linux/amd64` and `linux/arm64`, and which one arrives is decided at the
    # pull. Saying it now saves a support call about whisper being slow.
    if [ "$PLATFORM" = "mac" ] && [ "$(uname -m)" = "arm64" ]; then
        dim "Apple Silicon: image sẽ được kéo bản arm64 (chạy thẳng, không giả lập)."
    fi

    if [ "$DO_INSTALL" = "0" ]; then
        dim "Chế độ kiểm tra: không cài gì, không sửa gì."
    fi
}

# `sed -i` takes an argument on BSD/macOS and none on GNU. Everything in this
# script that edits .env goes through here, because the failure is silent on
# the platform nobody tested on: BSD sed reads the *script* as the backup
# suffix and leaves the file alone.
inplace_sed() {
    if sed --version >/dev/null 2>&1; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

powershell() {
    powershell.exe -NoProfile -NonInteractive -Command "$1"
}

has_command() { command -v "$1" >/dev/null 2>&1; }

# winget is the installer Windows ships with. It is not always on PATH inside
# Git Bash - the WindowsApps folder is a per-user alias - so it is reached
# through PowerShell when the direct call finds nothing.
winget_install() {
    local id="$1" name="$2"
    if has_command winget; then
        winget install --id "$id" -e --accept-package-agreements \
               --accept-source-agreements --disable-interactivity && return 0
    fi
    powershell "winget install --id $id -e --accept-package-agreements --accept-source-agreements --disable-interactivity" && return 0
    bad "$name: cài tự động không được. Cài tay rồi chạy lại: $id"
    return 1
}

# -------------------------------------------------------------------- docker

docker_ok() {
    local out
    out="$(docker info --format '{{.ServerVersion}}' 2>&1)" || return 1
    printf '%s' "$out" | grep -qiE '^[0-9]' || return 1
}

install_docker_desktop() {
    if [ "$PLATFORM" = "mac" ]; then
        if has_command brew; then
            note "Chưa có Docker. Cài bằng Homebrew (có thể hỏi mật khẩu máy)..."
            brew install --cask docker && return 0
        fi
        bad "Chưa có Docker Desktop và cũng không có Homebrew. Tải tại https://www.docker.com/products/docker-desktop/ rồi chạy lại script này."
        return 1
    fi
    note "Chưa có Docker. Cài bằng winget (có thể mất vài phút)..."
    winget_install Docker.DockerDesktop "Docker Desktop"
}

start_docker_desktop() {
    if [ "$PLATFORM" = "mac" ]; then
        [ -d "/Applications/Docker.app" ] || return 1
        note "Đang mở Docker Desktop..."
        open -a Docker >/dev/null 2>&1 &
        return 0
    fi
    local exe="/c/Program Files/Docker/Docker/Docker Desktop.exe"
    [ -x "$exe" ] || return 1
    note "Đang mở Docker Desktop..."
    "$exe" >/dev/null 2>&1 &
    return 0
}

ensure_docker() {
    step "Docker Desktop"

    if ! has_command docker; then
        if [ "$DO_INSTALL" = "0" ]; then
            bad "Chưa có Docker Desktop"
            return
        fi
        install_docker_desktop || return
        warn "Docker Desktop đã cài. Lần đầu cần mở nó một lần (và trên Windows có thể phải khởi động lại máy) - chạy lại script này sau đó."
    fi

    if docker_ok; then
        ok "Docker đang chạy: $(docker --version | cut -d, -f1)"
        return
    fi

    if [ "$DO_INSTALL" = "0" ]; then
        bad "Docker có mặt nhưng chưa chạy (mở Docker Desktop rồi chạy lại)"
        return
    fi

    note "Docker chưa chạy. Đang thử mở Docker Desktop..."
    start_docker_desktop || true
    local waited=0
    while [ "$waited" -lt 240 ]; do
        if docker_ok; then
            ok "Docker đã lên sau ${waited}s"
            return
        fi
        sleep 5
        waited=$((waited + 5))
        [ $((waited % 30)) -eq 0 ] && dim "vẫn đang đợi Docker... (${waited}s)"
    done
    warn "Docker chưa lên sau 4 phút. Mở Docker Desktop bằng tay, đợi tới khi nó báo 'Engine running', rồi chạy lại script này."
}

compose() {
    docker compose "$@"
}

# ----------------------------------------------------------------------- adb

ADB_DIR="$HERE/platform-tools"
ADB="$ADB_DIR/adb"

# Google publishes the same tools per platform. The Android Debug Bridge is a
# client plus a *server*; the server is what sees the phone, and it has to run
# on this machine - the container reaches it over TCP at 5037 (the image is
# built with those variables).
adb_url() {
    if [ "$PLATFORM" = "mac" ]; then
        printf '%s' 'https://dl.google.com/android/repository/platform-tools-latest-darwin.zip'
    else
        printf '%s' 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip'
    fi
}

unzip_to_here() {
    local zip="$1"
    if [ "$PLATFORM" = "mac" ]; then
        unzip -q -o "$zip" -d "$HERE"
    else
        # Git Bash has no unzip. PowerShell does, and it is on every Windows.
        powershell "Expand-Archive -LiteralPath '$(cygpath -w "$zip")' -DestinationPath '$(cygpath -w "$HERE")' -Force"
    fi
}

ensure_adb() {
    step "adb (Android platform-tools)"
    [ "$PLATFORM" = "windows" ] && ADB="$ADB_DIR/adb.exe"

    if [ ! -x "$ADB" ] && has_command adb; then
        # Somebody already installed platform-tools somewhere on PATH - Homebrew
        # on macOS, a winget package on Windows. Nothing to download, but the
        # server still has to be started below.
        ADB="$(command -v adb)"
        ok "Đã có adb trên PATH: $ADB"
    elif [ ! -x "$ADB" ]; then
        if [ "$DO_INSTALL" = "0" ]; then
            bad "Chưa có adb"
            return
        fi
        note "Đang tải platform-tools từ Google (~10 MB)..."
        local zip="$HERE/platform-tools.zip"
        if ! curl -fL --retry 2 -o "$zip" "$(adb_url)"; then
            rm -f "$zip"
            bad "Tải platform-tools không được. Kiểm tra mạng rồi chạy lại."
            return
        fi
        if ! unzip_to_here "$zip"; then
            bad "Giải nén platform-tools không được (file: $zip)"
            return
        fi
        rm -f "$zip"
        if [ -x "$ADB" ]; then
            ok "Đã tải và giải nén vào $ADB_DIR"
        else
            warn "Đã giải nén nhưng không thấy $ADB - kiểm tra thư mục platform-tools"
        fi
    else
        ok "adb có sẵn ở $ADB_DIR"
    fi

    # On PATH for the *user*, so that opening a new terminal and typing `adb`
    # works - the pairing steps for a modern Android phone are typed by hand,
    # and a script that leaves adb reachable only from itself is a script
    # nobody can follow.
    if [ "$DO_INSTALL" = "1" ] && ! has_command adb; then
        if [ "$PLATFORM" = "mac" ]; then
            # Not written into ~/.zshrc: editing somebody's shell profile from
            # an installer is a change they did not ask for and will not see.
            dim "Muốn gõ 'adb' ở terminal bất kỳ thì thêm dòng này vào ~/.zshrc:"
            dim "  export PATH=\"$ADB_DIR:\$PATH\""
        else
            # Set through PowerShell rather than `setx`, which truncates PATH
            # at 1024 characters. `$p` is null on an account that has never had
            # a user PATH of its own, and `.TrimEnd` on null throws - which
            # would leave adb missing from PATH with nothing printed.
            local win_dir
            win_dir="$(cygpath -w "$ADB_DIR" 2>/dev/null || printf '%s' "$ADB_DIR")"
            powershell "\$p=[Environment]::GetEnvironmentVariable('Path','User'); if ([string]::IsNullOrEmpty(\$p)) { \$p='' } else { \$p=\$p.TrimEnd(';') }; if (\$p -notlike '*platform-tools*') { [Environment]::SetEnvironmentVariable('Path', ((\$p + ';' + '$win_dir').TrimStart(';')), 'User') }" \
                && dim "Đã thêm $win_dir vào PATH của người dùng (mở terminal mới là có hiệu lực)"
        fi
    fi

    # The container reaches this server over TCP at host.docker.internal:5037
    # - the image is built with those three variables. Starting it here means
    # the phone is reachable from inside the container without anybody
    # remembering a command.
    if "$ADB" start-server >/dev/null 2>&1; then
        local devices
        devices="$("$ADB" devices | tail -n +2 | grep -c 'device$' || true)"
        if [ "${devices:-0}" -gt 0 ]; then
            ok "adb server đang chạy, thấy ${devices} điện thoại"
        else
            warn "adb server đang chạy nhưng chưa thấy điện thoại nào (cắm cáp + bật USB debugging, hoặc ghép qua Wi-Fi - xem cuối script)"
        fi
    else
        bad "Không chạy được adb server"
    fi
}

# --------------------------------------------------------------------- chrome

chrome_path() {
    if [ "$PLATFORM" = "mac" ]; then
        printf '%s' '/Applications/Google Chrome.app'
        return
    fi
    # Three places on Windows, because a per-user install (no administrator
    # rights) lands in the last one - `open-chrome.bat` looks in the same
    # three, and the two lists have to agree or one of them says "no Chrome"
    # about a machine that has one.
    local chrome
    # `${LOCALAPPDATA:-}` and not `$LOCALAPPDATA`: this function is also called
    # on macOS, where that variable does not exist and `set -u` would end the
    # script with "unbound variable" - an installer dying on a machine that is
    # fine.
    for chrome in "/c/Program Files/Google/Chrome/Application/chrome.exe" \
                  "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
                  "${LOCALAPPDATA:-}/Google/Chrome/Application/chrome.exe" \
                  "$HOME/AppData/Local/Google/Chrome/Application/chrome.exe"; do
        if [ -x "$chrome" ]; then
            printf '%s' "$chrome"
            return
        fi
    done
}

ensure_chrome() {
    step "Chrome (cho phiên đăng nhập Shopee)"
    local chrome
    chrome="$(chrome_path)"

    if [ -n "$chrome" ]; then
        ok "Chrome có sẵn"
        return
    fi
    if [ "$DO_INSTALL" = "0" ]; then
        bad "Chưa có Chrome"
        return
    fi
    if [ "$PLATFORM" = "mac" ]; then
        if has_command brew && brew install --cask google-chrome; then
            ok "Đã cài Chrome"
        else
            warn "Chrome chưa cài được. Tải tại https://www.google.com/chrome/ rồi chạy lại - màn đọc link sản phẩm Shopee cần nó."
        fi
        return
    fi
    note "Chưa có Chrome. Cài bằng winget..."
    if winget_install Google.Chrome "Chrome"; then
        ok "Đã cài Chrome"
    else
        warn "Chrome chưa cài được. Màn đọc link sản phẩm Shopee sẽ không dùng được cho tới khi có."
    fi
}

# ----------------------------------------------------------------- the folders

DIRS=(
    data/videos data/database data/app-logs data/logs data/cookies data/input
    data/public data/models/hf-cache data/models/whisper data/models/videowipe
    data/mpt-data/storage
)

make_dirs() {
    step "Thư mục dữ liệu"
    [ "$DO_INSTALL" = "1" ] || { dim "bỏ qua (chế độ kiểm tra)"; return; }
    local missing=0
    for dir in "${DIRS[@]}"; do
        [ -d "$HERE/$dir" ] || { mkdir -p "$HERE/$dir"; missing=$((missing + 1)); }
    done
    ok "Đã tạo $missing thư mục còn thiếu (dữ liệu nằm trong ./data)"
}

# ---------------------------------------------------------------- the settings

write_env() {
    step "File cấu hình .env"

    if [ -f "$ENV_FILE" ]; then
        ok ".env đã có - giữ nguyên, không ghi đè"
    else
        if [ "$DO_INSTALL" = "0" ]; then
            bad "Chưa có .env"
            return
        fi
        cp "$HERE/.env.example" "$ENV_FILE" || { bad "Không tạo được .env"; return; }
        # The one value that cannot be a default: this machine's own path, as
        # this machine spells it.
        if grep -q '^SHORTGPT_VIDEOS_HOST_DIR=' "$ENV_FILE"; then
            inplace_sed "s|^SHORTGPT_VIDEOS_HOST_DIR=.*|SHORTGPT_VIDEOS_HOST_DIR=$HOST_HERE/data/videos|" "$ENV_FILE"
        else
            printf '\nSHORTGPT_VIDEOS_HOST_DIR=%s/data/videos\n' "$HOST_HERE" >> "$ENV_FILE"
        fi
        ok "Đã tạo .env"
    fi

    # Two keys, two different screens that stop working without them: the
    # script's own subject line ("dịch" and "video tự động" both call a model)
    # and the stock footage. Asked once, and only when somebody is there to
    # answer - a value already in .env is never asked about again.
    if [ "$DO_INSTALL" = "1" ] && [ -t 0 ]; then
        ask_key OPENAI_API_KEY "Key DeepSeek/OpenAI (viết kịch bản, dịch)"
        ask_key PEXELS_API_KEY "Key Pexels (kho video nền, miễn phí)"
    fi
    report_keys
}

ask_key() {
    local name="$1" label="$2" current
    current="$(grep -E "^$name=" "$ENV_FILE" | head -1 | cut -d= -f2-)"
    if [ -n "$current" ]; then
        ok "$name đã có"
        return
    fi
    dim "$label - bỏ trống nếu chưa có, điền sau bằng cách mở file .env"
    printf '    %s: ' "$name"
    local value escaped
    read -r value
    [ -n "$value" ] || { warn "$name còn trống"; return; }
    # A key with a `&` or a `|` in it would be eaten by sed as a replacement
    # directive rather than written as itself.
    escaped="$(printf '%s' "$value" | sed 's/[&|\\]/\\&/g')"
    inplace_sed "s|^$name=.*|$name=$escaped|" "$ENV_FILE"
    ok "$name đã điền"
}

report_keys() {
    local name value
    for name in OPENAI_API_KEY PEXELS_API_KEY; do
        value="$(grep -E "^$name=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)"
        if [ -n "$value" ]; then
            ok "$name có giá trị"
        else
            warn "$name còn trống - mở $ENV_FILE và điền"
        fi
    done
}

# The files the image carries inside it: background music, the brand
# templates, the logo the app's own header loads. They live in the image at
# /app/public, and compose mounts an empty folder over that path so the
# downloads the app writes are not lost at the next update. Copying them out
# once is what keeps both: nothing here overwrites what is already on disk.
seed_public() {
    step "Tài nguyên sẵn có (nhạc nền, logo, template)"
    if [ "$DO_INSTALL" = "0" ]; then
        dim "bỏ qua (chế độ kiểm tra)"
        return
    fi
    if [ -n "$(ls -A "$HERE/data/public" 2>/dev/null)" ]; then
        ok "Đã có sẵn trong ./data/public"
        return
    fi
    local image
    image="$(env_value SHORTGPT_IMAGE 'ghcr.io/linhdev/shortgpt:latest')"
    docker image inspect "$image" >/dev/null 2>&1 || {
        warn "Chưa có image $image - chạy lại script này sau khi tải image xong."
        return
    }
    # A container that is only created, never started, so that the copy comes
    # from the image and not from the (still empty) mounted folder. Any
    # leftover from a run that was interrupted goes first - `create` refuses a
    # name that is already taken, and the failure would be silent.
    #
    # The destination is handed over as a *Windows* path on Windows. `docker`
    # there is docker.exe, which does not know what `/c/Users/...` is, and
    # whether the shell rewrites it on the way out depends on how the script
    # was invoked - this copy is worth not leaving to that. Measured
    # 2026-10-04, running with MSYS_NO_PATHCONV: the copy failed and said only
    # that it had. macOS needs no conversion, and has no `cygpath`.
    local target="$HERE/data/public"
    if [ "$PLATFORM" = "windows" ]; then
        target="$(cygpath -w "$target" 2>/dev/null || printf '%s' "$target")"
    fi
    docker rm -f shortgpt-seed >/dev/null 2>&1
    docker create --name shortgpt-seed "$image" >/dev/null 2>&1 && {
        if docker cp shortgpt-seed:/app/public/. "$target" >/dev/null 2>&1; then
            ok "Đã chép tài nguyên từ image ra ./data/public"
        else
            warn "Không chép được tài nguyên từ image (thư mục ./data/public để trống - chạy lại script này sẽ thử lại)"
        fi
        docker rm -f shortgpt-seed >/dev/null 2>&1
    }
}

env_value() {
    local name="$1" fallback="$2" value
    value="$(grep -E "^$name=" "$ENV_FILE" 2>/dev/null | head -1 | cut -d= -f2-)"
    printf '%s' "${value:-$fallback}"
}

# The port the app is published on, which is the one value the report and the
# wait both have to agree with the compose file about. Default 31415; a machine
# that already runs something there sets SHORTGPT_PORT in .env.
app_port() {
    # Shell first, then .env - *the same precedence compose uses*. Measured
    # 2026-10-04: with the other order, a run with SHORTGPT_PORT exported had
    # compose publishing 31416 and this waiting on 31415, and the wait passed
    # against whatever else was on that port.
    printf '%s' "${SHORTGPT_PORT:-$(env_value SHORTGPT_PORT 31415)}"
}

# --------------------------------------------------------------- the containers

pull_images() {
    step "Tải image từ ghcr"
    if [ "$DO_INSTALL" = "0" ]; then
        dim "bỏ qua (chế độ kiểm tra)"
        return
    fi
    # Streamed, not captured. The first install pulls ~3.7 GB, and a script
    # that shows nothing for ten minutes reads as a script that has hung -
    # which is a support call, not a `docker compose pull`. The output is
    # still kept, because the sentence below is built from what it said.
    local output status progress
    progress="$(mktemp -t shortgpt-pull-XXXXXX)"
    compose pull 2>&1 | tee "$progress"
    status="${PIPESTATUS[0]}"
    output="$(cat "$progress")"
    rm -f "$progress"
    if [ "$status" -eq 0 ]; then
        ok "Đã tải image"
        # Which build of it. Both images are published for amd64 and arm64, so
        # this is the line that answers "will whisper run at a sane speed on
        # this machine" - an arm64 Mac that got the amd64 image is running
        # under emulation, and that is worth saying out loud before somebody
        # wonders why a transcript takes ten minutes.
        local image arch machine want
        image="$(env_value SHORTGPT_IMAGE 'ghcr.io/linhdev/shortgpt:latest')"
        arch="$(docker image inspect "$image" --format '{{.Os}}/{{.Architecture}}' 2>/dev/null || true)"
        machine="$(uname -m)"
        case "$machine" in
            x86_64|amd64)   want=amd64 ;;
            arm64|aarch64)  want=arm64 ;;
            *)              want="$machine" ;;
        esac
        case "$arch" in
            '')            dim "Không đọc được kiến trúc của image" ;;
            *"/$want")     ok  "Image: $arch - đúng kiến trúc của máy này" ;;
            *)             warn "Image: $arch, nhưng máy này là $want - vẫn chạy, nhưng qua giả lập nên chậm hơn nhiều. Xem README." ;;
        esac
        return
    fi
    printf '%s\n' "$output" | tail -20 | sed 's/^/        /'
    # The public images need no account. A private one does, and the message
    # Docker prints for it ("unauthorized") names the registry but not the
    # command that fixes it.
    if printf '%s' "$output" | grep -qiE 'unauthorized|denied'; then
        bad "Image không tải được: cần đăng nhập ghcr. Chạy: docker login ghcr.io -u <tài-khoản-github> (mật khẩu là Personal Access Token có quyền read:packages), rồi chạy lại script này."
    else
        bad "Tải image không được - xem log ở trên"
    fi
}

start_containers() {
    step "Chạy container"
    if [ "$DO_INSTALL" = "0" ]; then
        dim "bỏ qua (chế độ kiểm tra)"
        return
    fi

    # A `shortgpt` service in *this* compose project that is already running
    # some other image is the machine this was developed on - there it is built
    # from the checkout with the source mounted over it, and `docker compose up
    # -d` here would replace it with the published image, silently and for
    # good. Stopping is the honest answer: this folder is for the customer's
    # machine.
    #
    # Asked of compose, by service, not of docker by container name. Measured
    # 2026-10-04: with the name, a copy of this folder running under its own
    # project name refused to start because the *development* container
    # happened to be called `shortgpt` - a guard against one accident that
    # caused another.
    local existing id wanted
    id="$(compose ps -q shortgpt 2>/dev/null | head -1)"
    existing="$(docker inspect -f '{{.Config.Image}}' "$id" 2>/dev/null \
                | tr -d '\r\n' || true)"
    wanted="$(env_value SHORTGPT_IMAGE 'ghcr.io/linhdev/shortgpt:latest')"
    if [ -n "$existing" ] && [ "$existing" != "$wanted" ]; then
        bad "Đang có container tên 'shortgpt' chạy image khác ($existing). Đây có thể là máy phát triển - thư mục này dành cho máy khách hàng, chạy ở đây sẽ thay thế container đó."
        return
    fi

    if ! compose up -d; then
        bad "Không chạy được container. Xem: docker compose logs --tail 50"
        return
    fi
    ok "Đã chạy: $(compose ps --services --filter status=running | tr '\n' ' ')"
}

wait_for_app() {
    local port
    port="$(app_port)"
    step "Đợi app trả lời (http://localhost:$port)"
    if [ "$DO_INSTALL" = "0" ]; then
        dim "bỏ qua (chế độ kiểm tra)"
        return
    fi
    local waited=0 code
    while [ "$waited" -lt 300 ]; do
        code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://localhost:$port/" || true)"
        if [ "$code" = "200" ]; then
            ok "App đã trả lời sau ${waited}s"
            return
        fi
        sleep 5
        waited=$((waited + 5))
        [ $((waited % 60)) -eq 0 ] && dim "vẫn đang đợi... (${waited}s)"
    done
    bad "App không trả lời sau 5 phút. Xem log: docker compose logs --tail 100 shortgpt"
}

check_containers() {
    step "Tình trạng container"
    # Asked of compose, by *service* name, rather than of docker by container
    # name: the service name is what this file and the compose file agree on,
    # and it keeps working when the containers are named something else - which
    # is what happens on a machine that already runs a copy of this stack.
    local service id state
    for service in shortgpt mpt-api mpt-webui; do
        id="$(compose ps -q "$service" 2>/dev/null | head -1)"
        state="$(docker inspect -f '{{.State.Status}}' "$id" 2>/dev/null \
                 | tr -d '\r\n' || true)"
        case "$state" in
            running) ok "$service: đang chạy" ;;
            '')      bad "$service: không có container nào" ;;
            *)       bad "$service: $state" ;;
        esac
    done
    # The two things the app needs from *this* machine, asked from inside the
    # container - which is where the app will ask them from.
    local app answer
    app="$(compose ps -q shortgpt 2>/dev/null | head -1)"
    [ -n "$app" ] || { warn "Không thấy container của app - bỏ qua phần kiểm tra kết nối"; return; }
    answer="$(docker exec "$app" python -c "
import socket
for host, port, what in (('host.docker.internal', 5037, 'adb server'),
                         ('host.docker.internal', 47831, 'Chrome Shopee')):
    probe = socket.socket(); probe.settimeout(2)
    try:
        probe.connect((host, port)); print(f'OK {what}')
    except OSError:
        print(f'NO {what}')
    finally:
        probe.close()
" 2>/dev/null || true)"
    if [ -z "$answer" ]; then
        warn "Không hỏi được từ trong container - kiểm tra sau khi app chạy"
        return
    fi
    case "$answer" in
        *"OK adb server"*)          ok "Container nối được tới adb server trên Windows" ;;
        *"NO adb server"*)          warn "Chưa nối được tới adb server (bình thường nếu chưa cắm điện thoại)" ;;
    esac
    case "$answer" in
        *"OK Chrome Shopee"*)       ok "Container nối được tới cửa sổ Chrome Shopee" ;;
        *"NO Chrome Shopee"*)       warn "Chưa thấy cửa sổ Chrome Shopee - mở open-chrome.bat rồi đăng nhập" ;;
    esac
}

# ------------------------------------------------------------------- the report

finish() {
    step "Tổng kết"
    local line state text failures=0 warnings=0
    for line in "${RESULTS[@]}"; do
        state="${line%%|*}"; text="${line#*|}"
        case "$state" in
            OK)   printf '    %s✓%s %s\n' "$GREEN" "$OFF" "$text" ;;
            WARN) printf '    %s!%s %s\n' "$YELLOW" "$OFF" "$text"; warnings=$((warnings + 1)) ;;
            FAIL) printf '    %sx%s %s\n' "$RED" "$OFF" "$text"; failures=$((failures + 1)) ;;
        esac
    done

    local how_chrome="${BOLD}open-chrome.bat${OFF} (nhấp đôi)"
    local how_start="nhấp đôi ${BOLD}start.bat${OFF}"
    if [ "$PLATFORM" = "mac" ]; then
        how_chrome="${BOLD}./open-chrome.sh${OFF}"
        how_start="${BOLD}./start.sh${OFF}"
    fi

    cat <<EOF

${BOLD}Còn bốn việc cần người làm - việc 3 chỉ khi đăng bài lên Page, việc 4 chỉ khi có mã bản quyền:${OFF}

  1. Kích hoạt bản quyền (nếu bạn đã có mã)
     - Mở app, vào Cấu hình, kéo xuống cuối tới mục "Bản quyền".
     - Dán mã dạng AR-XXXX-XXXX-XXXX-XXXX rồi bấm Kích hoạt.
     - Từ lúc đó app sẽ bắt buộc bản quyền: hết hạn là app ngừng
       làm việc cho tới khi gia hạn. Chưa có mã thì bỏ qua mục này.

  2. Đăng nhập Shopee (để đọc link sản phẩm và đăng bài)
     - Mở $how_chrome trong thư mục này.
     - Đăng nhập Shopee trong cửa sổ hiện ra, rồi ${BOLD}để cửa sổ đó mở${OFF}
       trong lúc dùng app.

  3. Nối điện thoại Android (để đăng bài lên Shopee Video)
     - Trên điện thoại: Bật "USB debugging" trong Tuỳ chọn nhà phát triển,
       cắm cáp, và chấp nhận hộp thoại "Cho phép gỡ lỗi USB".
     - Kiểm tra:  ${ADB} devices
     - Android 11 trở lên nối được qua Wi-Fi (không cần cáp):
         ${ADB} pair <ip>:<cổng>     # lấy ip:cổng ở mục "Ghép bằng mã" trên máy
         ${ADB} connect <ip>:<cổng>  # cổng này khác cổng ở bước pair

  4. Nối Facebook (chỉ khi đăng video lên Page)
     - Mở ${BOLD}HUONG-DAN-FACEBOOK.md${OFF} trong thư mục này - từng bước một,
       khoảng 10 phút, kèm ba lỗi hay gặp.
     - Cần một app Meta của chính bạn. Không có tên miền riêng thì làm theo
       mục "Cách khác: dán token" ở cuối file đó.

  Mở app:  ${BOLD}http://localhost:$(app_port)${OFF}   (hoặc $how_start)

  Nhật ký khi có trục trặc:
      docker compose logs --tail 100 shortgpt     # log của app
      ./data/logs/shopee/...                      # bằng chứng từng lượt đăng bài
EOF

    if [ "$failures" -gt 0 ]; then
        printf '\n%sCòn %d việc CHƯA xong (ô x ở trên) - app có thể vẫn chạy nhưng thiếu chức năng.%s\n' "$RED" "$failures" "$OFF"
        exit 1
    fi
    if [ "$warnings" -gt 0 ]; then
        printf '\n%sXong. Có %d việc cần để ý (ô ! ở trên).%s\n' "$YELLOW" "$warnings" "$OFF"
    else
        printf '\n%sMọi thứ đã sẵn sàng.%s\n' "$GREEN" "$OFF"
    fi
}

# ------------------------------------------------------------------------ main

printf '%s\n' "${BOLD}ShortGPT - cài đặt${OFF}"
dim "$(date '+%Y-%m-%d %H:%M')  |  $HERE"

check_shell
ensure_docker
ensure_adb
ensure_chrome
make_dirs
write_env

# Everything below this line needs a working Docker. When there is not one,
# the report has already said why and what to do - running the compose
# commands anyway would bury that under four more failures about the same
# thing.
if [ "$DO_INSTALL" = "1" ] && { ! has_command docker || ! docker_ok; }; then
    warn "Bỏ qua phần container: Docker chưa chạy"
    check_containers
    finish
fi

# After the pull, not before: seeding reads the resources out of the image,
# and on a first install there is no image yet.
pull_images
seed_public
start_containers
wait_for_app
check_containers
finish
