#!/vendor/bin/sh

if mount -o remount,rw /vendor;then
	if grep -qF ro.product.manufacturer /vendor/lib/hw/com.qti.chi.override.so;then
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/etc/init/hw/init.qcom.usb.rc
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib/hw/camera.qcom.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib/hw/com.qti.chi.override.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib/libsdmcore.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib/mediadrm/libwvdrmengine.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/bin/xtra-daemon 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib64/libsdmcore.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib64/libVDClearShot.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib64/mediadrm/libwvdrmengine.so 
		sed -i -e 's/ro.product.manufacturer/ro.product.Manufacturer/g' /vendor/lib64/libwvhidl.so 
	fi
	mount -o remount,ro /vendor	
fi
