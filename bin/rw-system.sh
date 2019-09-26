#!/system/bin/sh
# Based on phh script

if mount -o remount,rw /system;then
	resize2fs $(grep ' /system ' /proc/mounts |cut -d ' ' -f 1) || true
elif mount -o remount,rw /;then
	resize2fs /dev/root || true
fi
mount -o remount,ro /system || true
mount -o remount,ro / || true

mkdir -p /mnt/phh/
mount -t tmpfs -o rw,nodev,relatime,mode=755,gid=0 none /mnt/phh || true
mkdir /mnt/phh/empty_dir

if ! grep -qF CodeElixir /proc/version;then
	mount -o bind /system/etc/framework-res.apk  /system/framework/framework-res.apk
	# Default
	mount -o bind /system/etc/thermals/thermal-engine-custom-kernel.conf  /vendor/etc/thermal-engine.conf
else
	# Default
	mount -o bind /system/etc/thermals/thermal-engine-default.conf  /vendor/etc/thermal-engine.conf
	# # Light
	# mount -o bind /system/etc/thermals/thermal-engine-light.conf  /vendor/etc/thermal-engine.conf
	# # High
	# mount -o bind /system/etc/thermals/thermal-engine-high.conf  /vendor/etc/thermal-engine.conf
fi

# Custom thermal-engine
mount -o bind /system/etc/empty  /vendor/bin/thermal-engine

mount -o bind /system/etc/qdcm_calib_data_ebbg_fhd_video_dsi_panel.xml /vendor/etc/qdcm_calib_data_ebbg_fhd_video_dsi_panel.xml
mount -o bind /system/etc/qdcm_calib_data_tianma_fhd_video_dsi_panel.xml /vendor/etc/qdcm_calib_data_tianma_fhd_video_dsi_panel.xml

mount -o bind /system/lib64/soundfx/libvolumelistener.so /vendor/lib64/soundfx/libvolumelistener.so
mount -o bind /system/lib/soundfx/libvolumelistener.so /vendor/lib/soundfx/libvolumelistener.so

#Security path level fix
fixSPL() {
    if [ "$(getprop ro.product.cpu.abi)" = "armeabi-v7a" ]; then
        setprop ro.keymaster.mod 'AOSP on ARM32'
    else
        setprop ro.keymaster.mod 'AOSP on ARM64'
    fi
    img="$(find /dev/block -type l -name kernel"$(getprop ro.boot.slot_suffix)" | grep by-name | head -n 1)"
    [ -z "$img" ] && img="$(find /dev/block -type l -name boot"$(getprop ro.boot.slot_suffix)" | grep by-name | head -n 1)"
    if [ -n "$img" ]; then
        #Rewrite SPL/Android version if needed
        Arelease="$(getSPL "$img" android)"
        setprop ro.keymaster.xxx.release "$Arelease"
        setprop ro.keymaster.xxx.security_patch "$(getSPL "$img" spl)"

        getprop ro.vendor.build.fingerprint | grep -qiE '^samsung/' && return 0
        for f in \
            /vendor/lib64/hw/android.hardware.keymaster@3.0-impl-qti.so /vendor/lib/hw/android.hardware.keymaster@3.0-impl-qti.so \
            /system/lib64/vndk/libsoftkeymasterdevice.so /system/lib/vndk/libsoftkeymasterdevice.so;do
            [ ! -f "$f" ] && continue
            # shellcheck disable=SC2010
            ctxt="$(ls -lZ "$f" | grep -oE 'u:object_r:[^:]*:s0')"
            b="$(echo "$f" | tr / _)"

            cp -a "$f" "/mnt/phh/$b"
            sed -i \
                -e 's/ro.build.version.release/ro.keymaster.xxx.release/g' \
                -e 's/ro.build.version.security_patch/ro.keymaster.xxx.security_patch/g' \
                -e 's/ro.product.model/ro.keymaster.mod/g' \
                "/mnt/phh/$b"
            chcon "$ctxt" "/mnt/phh/$b"
            mount -o bind "/mnt/phh/$b" "$f"
        done
        if [ "$(getprop init.svc.keymaster-3-0)" = "running" ]; then
            setprop ctl.restart keymaster-3-0
        fi
        if [ "$(getprop init.svc.teed)" = "running" ]; then
            setprop ctl.restart teed
        fi
    fi
}

fixSPL