#!/system/bin/sh
# sunny_memtune: applied late (after boot) so init/vendor scripts do not overwrite it.
# Disable or delete /data/adb/modules/sunny_memtune and reboot to revert.
MODDIR=${0%/*}
LOG=$MODDIR/last_run.log

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 20

w() { [ -w "$2" ] && echo "$1" > "$2" && echo "$2=$(cat $2)" >> $LOG; }
echo "applied $(date)" > $LOG

# zswap (zstd/zsmalloc) is the real swap backend; vbswap0 is a fake 4 GB device.
# Measured ~4.5:1 effective ratio, while file cache refaulted ~1100 pages/s.
# OPLUS_MM_HACKS allows 0..200 and uses file_prio = 200 - swappiness, so >100
# prefers compressing cold anon over evicting file pages that get re-read.
w 160 /proc/sys/vm/swappiness
# Swappiness used in direct reclaim (OPLUS hack, default 60 = file-biased).
# 100 = equal weighting; keeps synchronous zstd work bounded in app threads.
w 100 /proc/sys/vm/direct_swappiness
# lz4kd decompresses several times faster than zstd: shorter swap-in stalls.
w lz4kd /sys/module/zswap/parameters/compressor

# Deliberately NOT changed: watermark_scale_factor / extra_free_kbytes (lmkd's
# "watermark is breached" kills compare free pages against the zone low
# watermark, so raising it makes lmkd kill earlier), lmkd props, zswap
# compressor/zpool, I/O scheduler, CPU governor.
