#!/bin/bash
set -euo pipefail

fn_git_clean() {
  git clean -xdf
  git checkout .
}

OUT_DIR="$PWD/out"
ROOT="$PWD"
EMCC_FLAGS_DEBUG="-Os -g3"
EMCC_FLAGS_RELEASE="-Oz -flto"

export CPPFLAGS="-I$OUT_DIR/include"
export LDFLAGS="-L$OUT_DIR/lib"
export PKG_CONFIG_PATH="$OUT_DIR/lib/pkgconfig"
export EM_PKG_CONFIG_PATH="$PKG_CONFIG_PATH"
export CFLAGS="$EMCC_FLAGS_RELEASE"
export CXXFLAGS="$CFLAGS"

mkdir -p "$OUT_DIR"

cd "$ROOT/lib/ghostscript"
fn_git_clean
emconfigure ./autogen.sh \
  CCAUX=gcc CFLAGSAUX= CPPFLAGSAUX= \
  --host="wasm32-unknown-linux" \
  --prefix="$OUT_DIR" \
  --disable-threading \
  --disable-cups \
  --disable-dbus \
  --disable-gtk \
  --with-drivers=FILES \
  --with-arch_h="$ROOT/arch_wasm.h"
# TODO: remove `EMULATE_FUNCTION_POINTER_CASTS`: https://github.com/emscripten-core/emscripten/issues/16126

export GS_LDFLAGS="\
  -lnodefs.js -lworkerfs.js \
  --pre-js "$ROOT/js/pre.js" \
  --post-js "$ROOT/js/post.js" \
  --closure 1 \
  -s USE_ZLIB=1 \
  -s EMULATE_FUNCTION_POINTER_CASTS=1 \
  -s BINARYEN_EXTRA_PASSES=\"--pass-arg=max-func-params@39\" \
  -s WASM_BIGINT=1 \
  -s INITIAL_MEMORY=67108864 \
  -s ALLOW_MEMORY_GROWTH=1 \
  -s EXPORTED_RUNTIME_METHODS='[\"callMain\",\"FS\",\"NODEFS\",\"WORKERFS\",\"ENV\"]' \
  -s INCOMING_MODULE_JS_API='[\"noInitialRun\",\"noFSInit\",\"locateFile\",\"preRun\",\"instantiateWasm\"]' \
  -s NO_DISABLE_EXCEPTION_CATCHING=1 \
  -s MODULARIZE=1 \
  -s EXIT_RUNTIME=1 \
"

emmake make \
  XE=".js" \
  LDFLAGS="$LDFLAGS $GS_LDFLAGS" \
  -j install

mkdir -p "$ROOT/dist"
cd "$ROOT/dist"
cp $ROOT/lib/ghostscript/bin/gs.* .
