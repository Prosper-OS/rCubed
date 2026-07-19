#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: scripts/package-steamdeck.sh [options]

Builds a native Steam Deck / SteamOS Linux x86_64 captive-runtime bundle.

Options:
  --air-home PATH       Linux HARMAN AIR SDK path. Defaults to AIR_HOME or AIR_SDK_LINUX.
  --version VERSION     Build version string. Defaults to R3_VERSION or 2.0.4.
  --output-dir PATH     Bundle directory. Defaults to dist/steamdeck/R3Air.<version>.SteamDeck.Native.x86_64.
  --skip-compile        Package bin/release/R3Air.swf without compiling it first.
  --check               Validate prerequisites only.
  -h, --help            Show this help.

Environment:
  AIR_HOME              Linux HARMAN AIR SDK path.
  AIR_SDK_LINUX         Alternative Linux HARMAN AIR SDK path.
  SCORE_SAVE_SALT       Score-save salt for release-compatible builds.
  R3_DATESTAMP          Release datestamp. Defaults to today's date.
  R3_AIR_VERSION_NUMBER AIR descriptor versionNumber. Defaults to the numeric part of R3_VERSION.
  AIR_KEYSTORE          Optional signing certificate path for ADT.
  AIR_STOREPASS         Optional signing certificate password for ADT.
  AIR_REFRESH_LICENSE   Set to 1 to run ADT's license refresh before packaging.
  AIR_LICENSE_DEV_ID    Optional HARMAN AIR commercial license developer id for refresh.
EOF
}

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

quote_arg() {
    printf '%q' "$1"
}

cleanup_paths=()
cleanup() {
    local path
    for path in "${cleanup_paths[@]}"; do
        if [[ -n "$path" && -f "$path" ]]; then
            rm -f "$path"
        fi
    done
}
trap cleanup EXIT

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
local_toolchain="${R3_STEAMDECK_TOOLCHAIN:-$HOME/.local/r3-steamdeck-toolchain}"
if [[ -d "$local_toolchain/node/bin" ]]; then
    export PATH="$local_toolchain/node/bin:$PATH"
fi
if [[ -d "$local_toolchain/jdk/bin" ]]; then
    export PATH="$local_toolchain/jdk/bin:$PATH"
fi

air_home="${AIR_HOME:-${AIR_SDK_LINUX:-}}"
version="${R3_VERSION:-2.0.4}"
output_dir=""
skip_compile=0
check_only=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --air-home)
            [[ $# -ge 2 ]] || fail "--air-home requires a path"
            air_home="$2"
            shift 2
            ;;
        --version)
            [[ $# -ge 2 ]] || fail "--version requires a value"
            version="$2"
            shift 2
            ;;
        --output-dir)
            [[ $# -ge 2 ]] || fail "--output-dir requires a path"
            output_dir="$2"
            shift 2
            ;;
        --skip-compile)
            skip_compile=1
            shift
            ;;
        --check)
            check_only=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            fail "Unknown option: $1"
            ;;
    esac
done

kernel="$(uname -s)"
machine="$(uname -m)"
[[ "$kernel" == "Linux" ]] || fail "Steam Deck native packaging must run on Linux or WSL, not $kernel"
case "$machine" in
    x86_64|amd64) ;;
    *) fail "Steam Deck native packaging requires Linux x86_64. Current architecture: $machine" ;;
esac

require_command python3
require_command java

if [[ -z "$air_home" ]]; then
    fail "AIR_HOME is required. Install the commercial HARMAN AIR SDK for Linux x86_64, then run AIR_HOME=/path/to/AIRSDK scripts/package-steamdeck.sh"
fi

[[ -d "$air_home" ]] || fail "AIR_HOME does not exist: $air_home"
air_home="$(cd "$air_home" && pwd -P)"
[[ -f "$air_home/lib/adt.jar" ]] || fail "AIR_HOME is not a Linux AIR SDK with lib/adt.jar: $air_home"

if [[ -n "${AIR_KEYSTORE:-}" && ! -f "${AIR_KEYSTORE}" ]]; then
    fail "AIR_KEYSTORE does not exist: ${AIR_KEYSTORE}"
fi

printf 'Using AIR SDK: %s\n' "$air_home"
java -jar "$air_home/lib/adt.jar" -version >/dev/null

if [[ "${AIR_REFRESH_LICENSE:-0}" == "1" || -n "${AIR_LICENSE_DEV_ID:-}" ]]; then
    license_args=()
    if [[ -n "${AIR_LICENSE_DEV_ID:-}" ]]; then
        license_args+=("-licenseDevID" "$AIR_LICENSE_DEV_ID")
    fi
    license_args+=("-license")
    printf 'Refreshing HARMAN AIR license status...\n'
    java -jar "$air_home/lib/adt.jar" "${license_args[@]}"
fi

if [[ "$check_only" -eq 1 ]]; then
    printf 'Steam Deck native packaging prerequisites are present.\n'
    exit 0
fi

if [[ -z "$output_dir" ]]; then
    output_dir="$repo_root/dist/steamdeck/R3Air.${version}.SteamDeck.Native.x86_64"
elif [[ "$output_dir" != /* ]]; then
    output_dir="$repo_root/$output_dir"
fi
output_dir="$(python3 -c 'import os,sys; print(os.path.abspath(sys.argv[1]))' "$output_dir")"

case "$output_dir" in
    "$repo_root"/dist/steamdeck/*) ;;
    *) fail "Refusing to write outside repo dist/steamdeck: $output_dir" ;;
esac

dist_root="$repo_root/dist/steamdeck"
tmp_root="$dist_root/tmp"
mkdir -p "$tmp_root"

date_stamp="${R3_DATESTAMP:-$(date +%F)}"
score_salt="${SCORE_SAVE_SALT:-wqo0zqz70wmKVXGSKL1F}"
air_version="${R3_AIR_VERSION_NUMBER:-$(python3 - "$version" <<'PY'
import re
import sys

match = re.search(r"\d+(?:\.\d+){0,2}", sys.argv[1])
print(match.group(0) if match else "2.0.4")
PY
)}"

if [[ "$skip_compile" -eq 0 ]]; then
    require_command node

    temp_config="$repo_root/asconfig.steamdeck.local.$$.json"
    cleanup_paths+=("$temp_config")
    python3 - "$repo_root/asconfig.release.json" "$temp_config" "$date_stamp" "$score_salt" "$version" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
date_stamp = sys.argv[3]
score_salt = sys.argv[4]
version = sys.argv[5]

text = source.read_text(encoding="utf-8")
text = text.replace("#{DATESTAMP}#", date_stamp)
text = text.replace("#{SCORE_SAVE_SALT}#", score_salt)
text = text.replace("#{VERSION}#", version)
target.write_text(text, encoding="utf-8")
PY

    if [[ -x "$repo_root/node_modules/.bin/asconfigc" ]]; then
        asconfigc_cmd=("$repo_root/node_modules/.bin/asconfigc")
    else
        require_command npx
        asconfigc_cmd=(npx --yes asconfigc@1.9.0)
    fi

    printf 'Compiling release SWF for Steam Deck package...\n'
    "${asconfigc_cmd[@]}" --sdk "$air_home" --project "$temp_config"
else
    printf 'Skipping SWF compile; using existing bin/release/R3Air.swf\n'
fi

swf_path="$repo_root/bin/release/R3Air.swf"
[[ -f "$swf_path" ]] || fail "Missing compiled SWF: $swf_path"

descriptor="$tmp_root/application-steamdeck.xml"
python3 - "$repo_root/application.xml" "$descriptor" "$air_version" <<'PY'
import sys
import xml.etree.ElementTree as ET

source = sys.argv[1]
target = sys.argv[2]
version = sys.argv[3]
namespace = "http://ns.adobe.com/air/application/32.0"
ET.register_namespace("", namespace)

tree = ET.parse(source)
root = tree.getroot()
root.find(f"{{{namespace}}}versionNumber").text = version
root.find(f"{{{namespace}}}initialWindow/{{{namespace}}}content").text = "R3Air.swf"
tree.write(target, encoding="utf-8", xml_declaration=True)
PY

rm -rf "$output_dir"
mkdir -p "$output_dir"
rmdir "$output_dir"

adt_args=("-package")
if [[ -n "${AIR_KEYSTORE:-}" ]]; then
    adt_args+=("-storetype" "pkcs12" "-keystore" "$AIR_KEYSTORE")
    if [[ -n "${AIR_STOREPASS:-}" ]]; then
        adt_args+=("-storepass" "$AIR_STOREPASS")
    fi
fi
adt_args+=(
    "-target" "bundle"
    "-arch" "x64"
    "$output_dir"
    "$descriptor"
    "-C" "$repo_root/bin/release" "R3Air.swf"
    "-C" "$repo_root" "data"
    "-C" "$repo_root" "changelog.txt"
)

printf 'Packaging native Linux captive-runtime bundle...\n'
printf 'java -jar %s/lib/adt.jar ' "$(quote_arg "$air_home")"
printf '%s ' "${adt_args[@]@Q}"
printf '\n'
java -jar "$air_home/lib/adt.jar" "${adt_args[@]}"

cp "$repo_root/steamdeck/r3-steamdeck.sh" "$output_dir/r3-steamdeck.sh"
cp "$repo_root/steamdeck/com.flashflashrevolution.r3.desktop" "$output_dir/com.flashflashrevolution.r3.desktop"
cp -R "$repo_root/steamdeck" "$output_dir/steamdeck"
chmod +x "$output_dir/r3-steamdeck.sh"

zip_path="${output_dir}.zip"
rm -f "$zip_path"
if command -v zip >/dev/null 2>&1; then
    (cd "$(dirname "$output_dir")" && zip -qr "$zip_path" "$(basename "$output_dir")")
else
    python3 - "$output_dir" "$zip_path" <<'PY'
import pathlib
import sys
import zipfile

bundle = pathlib.Path(sys.argv[1]).resolve()
zip_path = pathlib.Path(sys.argv[2]).resolve()
parent = bundle.parent

with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
    for path in bundle.rglob("*"):
        archive.write(path, path.relative_to(parent))
PY
fi

printf 'Steam Deck native package created:\n%s\n%s\n' "$output_dir" "$zip_path"
