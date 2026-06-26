#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------
# Usage:
#   ./build_v8_d8.sh <v8-commit-hash>
#   ./build_v8_d8.sh <v8-commit-hash> --coverage-on
# ------------------------------------------------------------

COVERAGE_ON=false

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <v8-commit-hash> [--coverage-on]"
  exit 1
fi

COMMIT="$1"

if [ "$#" -eq 2 ]; then
  case "$2" in
    --coverage-on)
      COVERAGE_ON=true
      ;;
    *)
      echo "[ERROR] Unknown option: $2"
      echo "Usage: $0 <v8-commit-hash> [--coverage-on]"
      exit 1
      ;;
  esac
fi

# Use the first 11 characters of the commit hash for directory names.
SHORT_COMMIT="${COMMIT:0:11}"

PARENT_DIR="v8_${SHORT_COMMIT}"
V8_DIR="v8"

if [ "$COVERAGE_ON" = true ]; then
  OUT_DIR="out/x64.coverage"
else
  OUT_DIR="out/x64.release"
fi

echo "[INFO] V8 commit: $COMMIT"
echo "[INFO] Parent directory: $PARENT_DIR"
echo "[INFO] V8 source directory: $V8_DIR"
echo "[INFO] Build output directory: $OUT_DIR"

# ------------------------------------------------------------
# Check required depot_tools commands.
# ------------------------------------------------------------

command -v fetch >/dev/null 2>&1 || {
  echo "[ERROR] fetch not found. Make sure depot_tools is in PATH."
  exit 1
}

command -v gclient >/dev/null 2>&1 || {
  echo "[ERROR] gclient not found. Make sure depot_tools is in PATH."
  exit 1
}

command -v gn >/dev/null 2>&1 || {
  echo "[ERROR] gn not found. Make sure depot_tools is in PATH."
  exit 1
}

command -v autoninja >/dev/null 2>&1 || {
  echo "[ERROR] autoninja not found. Make sure depot_tools is in PATH."
  exit 1
}

# ------------------------------------------------------------
# Some old V8/depot_tools scripts expect the command "python".
# If only python2 exists, create a local shim.
# ------------------------------------------------------------

if ! command -v python >/dev/null 2>&1; then
  if command -v python2 >/dev/null 2>&1; then
    echo "[INFO] python not found. Creating python -> python2 shim."
    mkdir -p "$HOME/pyshim"
    ln -sf "$(command -v python2)" "$HOME/pyshim/python"
    export PATH="$HOME/pyshim:$PATH"
  else
    echo "[ERROR] Neither python nor python2 found."
    exit 1
  fi
fi

# ------------------------------------------------------------
# Create parent directory, fetch V8, and rename the fetched v8
# directory to include the short commit hash.
# ------------------------------------------------------------

mkdir -p "$PARENT_DIR"
cd "$PARENT_DIR"

if [ ! -d "$V8_DIR" ]; then
  echo "[INFO] Fetching V8..."
  fetch v8
else
  echo "[INFO] Existing v8 directory found. Skipping fetch."
fi

cd "$V8_DIR"

git fetch --all --tags
git checkout "$COMMIT"

cd ..

echo "[INFO] Running gclient sync from parent directory..."
gclient sync

cd "$V8_DIR"

# ------------------------------------------------------------
# Check out the requested V8 commit.
# ------------------------------------------------------------

echo "[INFO] Fetching all git refs..."
git fetch --all --tags

echo "[INFO] Checking out target commit..."
git checkout "$COMMIT"

# ------------------------------------------------------------
# Download/update V8 dependencies for this commit.
# ------------------------------------------------------------

echo "[INFO] Running gclient sync..."
gclient sync

# ------------------------------------------------------------
# Work around GLIBCXX_3.4.30 mismatch.
# This forces the build to use the system libstdc++ instead of
# the older libstdc++ bundled with this old V8 toolchain.
# ------------------------------------------------------------

LIBSTDCXX="third_party/llvm-build/Release+Asserts/lib/libstdc++.so.6"

if [ -f "$LIBSTDCXX" ]; then
  if [ ! -f "${LIBSTDCXX}.bak" ]; then
    echo "[INFO] Moving bundled libstdc++.so.6 aside..."
    mv "$LIBSTDCXX" "${LIBSTDCXX}.bak"
  else
    echo "[INFO] Backup already exists. Removing bundled libstdc++.so.6..."
    rm -f "$LIBSTDCXX"
  fi
else
  echo "[INFO] Bundled libstdc++.so.6 not present. Skipping."
fi

# ------------------------------------------------------------
# Write GN build configuration.
# Default: release build.
# Optional: coverage build when --coverage-on is passed.
# ------------------------------------------------------------

echo "[INFO] Writing GN args..."
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

if [ "$COVERAGE_ON" = true ]; then
  echo "[INFO] Configuring coverage build."

  cat > "$OUT_DIR/args.gn" <<'EOF'
is_component_build = false
is_debug = false
target_cpu = "x64"
use_goma = false
goma_dir = "None"
v8_enable_backtrace = true
v8_enable_disassembler = true
v8_enable_object_print = true
v8_enable_verify_heap = true
EOF

else
  echo "[INFO] Configuring release build."

  cat > "$OUT_DIR/args.gn" <<'EOF'
is_component_build = false
is_debug = false
target_cpu = "x64"
use_goma = false
goma_dir = "None"
v8_enable_backtrace = true
v8_enable_disassembler = true
v8_enable_object_print = true
v8_enable_verify_heap = true
use_clang_coverage = true
EOF

fi

# ------------------------------------------------------------
# Generate Ninja files and build d8.
# ------------------------------------------------------------

echo "[INFO] Running gn gen..."
gn gen "$OUT_DIR"

echo "[INFO] Building d8..."
autoninja -C "$OUT_DIR" d8

echo "[DONE] d8 built successfully:"
ls -lh "$OUT_DIR/d8"

# ------------------------------------------------------------
# Show which libstdc++ the final d8 binary uses.
# ------------------------------------------------------------

echo "[INFO] libstdc++ used by d8:"
ldd "$OUT_DIR/d8" | grep stdc++ || true
