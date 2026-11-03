#!/bin/bash
# fbtest.sh <name> : fastboot-boot an already-packed release/boot-<name>.img once and report the result
export ANDROID_SERIAL=3d775d76; R=/Users/raibatsu/Downloads/sunny-kernel/release
[ -f $R/boot-$1.img ] || { echo "no image $1"; exit 1; }
adb reboot bootloader; timeout 60 bash -c 'until fastboot -s 3d775d76 devices | grep -q .; do sleep 2; done'
fastboot -s 3d775d76 boot $R/boot-$1.img 2>&1 | tail -1
timeout 200 adb wait-for-device && timeout 180 bash -c 'until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d "\r")" = "1" ]; do sleep 3; done'
echo "running kernel: $(adb shell uname -r 2>&1)"
