#!/usr/bin/env bash
# Tắt AutoReel. Dữ liệu trong ./data không bị động tới. Bản macOS của stop.bat.
set -u
cd "$(dirname "$0")" || exit 1
docker compose down
