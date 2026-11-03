# sunny kernel tools

Build/test tooling and the Magisk tuning module for the Redmi Note 10
(sunny/mojito, SM6150) running PixelOS, used with the kernel branches in this
repository.

## Branches

| Branch     | What it is |
|------------|------------|
| `optimize` | NetErnels 4.14.206 + MGLRU backport, HZ 300, HW AF/DBM, VM event counters |
| `mglru`    | Just the MGLRU backport (from AxionAOSP violet) |
| `lts`      | `optimize` merged up to 4.14.336 (AOSP android-4.14-stable) |
| `bliss`    | BlissRoms mojito kernel + NetErnels bits; does not boot on PixelOS |

`lts` carries fixes for two places where upstream LTS changes broke the CAF
code, both found by bisecting:

- `1c2859398ecd` extcon (4.14.283): CAF's `edev->bnh` was `devm_` allocated
  before `device_register()`; crashed during early boot.
- `2eef360cc361` sdhci (4.14.301): new early return in `sdhci_set_ios()`
  leaked CAF's `host->lock`; watchdog reset.

Plus `05c5ecbab06c` (Spectre-v2/BHB hardening on, Kryo 4xx MIDRs added to the
errata tables) and `274a4fec012a` (zpool GFP warning). The Bliss kernel very
likely needs the same two fixes.

## Building

`scripts/build.sh <worktree> [defconfig] [gcc|clang]` builds `Image` inside
the `sunny-builder` container (`docker build -t sunny-builder docker/`) into
the Docker volume `sunny-out-<worktree>`. The source must live on a
case-sensitive filesystem. Paths in the scripts point at
`~/Downloads/sunny-kernel`; adjust them if you rebuild elsewhere.

`scripts/testboot.sh <worktree> <name>` repacks the phone's current `boot_b`
(keeping Magisk) with the new `Image` using magiskboot on the device, then
`fastboot boot`s it once. Nothing is flashed; a reboot returns to the
flashed kernel. `scripts/fbtest.sh <name>` re-boots a saved
`release/boot-<name>.img`. Both pin `ANDROID_SERIAL` to the phone.

To flash a tested image: `fastboot flash boot_b release/boot-<name>.img`.
A PixelOS OTA replaces `boot`, which drops both the kernel and Magisk.

## Magisk module

`magisk/sunny_memtune` (v1.2): swappiness 160, direct_swappiness 100, zswap
compressor lz4kd, and lmkd/ART props in `system.prop`. Zip the directory
contents and install from Magisk, or copy to `/data/adb/modules/`.
