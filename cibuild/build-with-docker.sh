#!/bin/bash
echo "======== build-with-dockerl.sh : $(pwd)                 =========="
echo "======== Building all PGlite prerequisites using Docker =========="

trap 'echo caught interrupt and exiting;' INT

source .buildconfig

if [[ -z "$SDK_VERSION" || -z "$PG_VERSION" ]]; then
  echo "Missing SDK_VERSION and PG_VERSION env vars."
  echo "Source them from .buildconfig"
  exit 1
fi

IMG_NAME="electricsql/pglite-builder"
IMG_TAG="${PG_VERSION}_${SDK_VERSION}"
SDK_ARCHIVE="${SDK_ARCHIVE:-python3.13-wasm-sdk-Ubuntu-22.04.tar.lz4}"
WASI_SDK_ARCHIVE="${WASI_SDK_ARCHIVE:-python3.13-wasi-sdk-Ubuntu-22.04.tar.lz4}"
VOL="${VOL:-$(pwd)/packages/pglite}"

# -v "/$(pwd)/packages/pglite:/workspace/packages/pglite:rw" \
docker run \
  --rm \
  -e OBJDUMP=${OBJDUMP:-true} \
  -e SDK_ARCHIVE \
  -e WASI_SDK_ARCHIVE \
  -v "/$(pwd)/cibuild.sh:/workspace/cibuild.sh:z" \
  -v "/$(pwd)/.buildconfig:/workspace/.buildconfig:z" \
  -v "/$(pwd)/extra:/workspace/extra:z" \
  -v "/$(pwd)/cibuild:/workspace/cibuild:z" \
  -v "/$(pwd)/patches:/opt/patches:z" \
  -v "/$(pwd)/tests:/workspace/tests:z" \
  -v $VOL:/workspace/packages/pglite:z \
  $IMG_NAME:$IMG_TAG \
  bash /workspace/cibuild/build-all.sh
