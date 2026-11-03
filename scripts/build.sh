#!/bin/bash
# Builds the kernel in the sunny-builder container.
# Usage: build.sh <worktree-dir-name> [defconfig] [gcc|clang]
W=${1:-work}
CFG=${2:-neternels_defconfig}
TC=${3:-gcc}
K=/Users/raibatsu/Downloads/sunny-kernel
if [ "$TC" = clang ]; then
  MK="LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- CROSS_COMPILE_COMPAT=arm-linux-gnueabi-"
else
  MK="CROSS_COMPILE= CROSS_COMPILE_ARM32=arm-linux-gnueabi- CROSS_COMPILE_COMPAT=arm-linux-gnueabi-"
fi
docker volume create sunny-out-$W >/dev/null
docker run --rm -v $K:$K -v sunny-out-$W:/out -w $K/$W sunny-builder bash -c '
  git config --global --add safe.directory "*"
  export ARCH=arm64
  make O=/out '"$MK"' '"$CFG"' > /out/build.log 2>&1 &&
  make O=/out '"$MK"' -j$(nproc) Image >> /out/build.log 2>&1
  rc=$?
  grep -nE "error:|Error [0-9]" /out/build.log | head -30
  tail -5 /out/build.log
  ls -la /out/arch/arm64/boot/Image 2>&1
  exit $rc
'
