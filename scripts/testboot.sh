#!/bin/bash
# Repack the current boot_b (keeps Magisk) with the Image built in volume sunny-out-<worktree>,
# then fastboot-boot it once and wait for Android. Usage: testboot.sh <worktree> <name>
export ANDROID_SERIAL=3d775d76; W=$1; N=$2; R=/Users/raibatsu/Downloads/sunny-kernel/release
docker run --rm -v sunny-out-$W:/out -v $R:/rel sunny-builder cp /out/arch/arm64/boot/Image /rel/Image-$N || exit 1
adb push $R/Image-$N /data/local/tmp/Image_test >/dev/null || exit 1
adb shell 'su -c "mkdir -p /data/local/tmp/kpkg && cd /data/local/tmp/kpkg && rm -f kernel ramdisk.cpio new-boot.img && dd if=/dev/block/by-name/boot_b of=boot.img bs=4M 2>/dev/null && /data/adb/magisk/magiskboot unpack boot.img >/dev/null 2>&1 && cp ../Image_test kernel && /data/adb/magisk/magiskboot repack boot.img new-boot.img >/dev/null 2>&1 && chmod 644 new-boot.img"' || exit 1
adb pull /data/local/tmp/kpkg/new-boot.img $R/boot-$N.img >/dev/null || exit 1
adb reboot bootloader; timeout 60 bash -c 'until fastboot -s 3d775d76 devices | grep -q .; do sleep 2; done'
fastboot -s 3d775d76 boot $R/boot-$N.img 2>&1 | tail -1
timeout 200 adb wait-for-device && timeout 180 bash -c 'until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d "\r")" = "1" ]; do sleep 3; done'
echo "running kernel: $(adb shell uname -r 2>&1)"
