.PHONY: run clean kernel drm run2 busybox mount umount

# 设置各个仓库的目录
CUR_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/
BASE_DIR := $(CUR_DIR)/../
OUT := $(CUR_DIR)/out/
OUT_MOD := $(OUT)/modules/
SHARE_DIR := $(CUR_DIR)/share/
KERNEL_DIR := $(BASE_DIR)/linux/
BUSYBOX_DIR := $(BASE_DIR)/busybox

#busybox:
#	

mount:
	mkdir -p $(OUT)/rootfs
	sudo mount $(OUT)/rootfs.img $(OUT)/rootfs

umount:
	sudo umount $(OUT)/rootfs

drm:
	mkdir -p $(OUT_MOD)
	rm -rf $(OUT_MOD)/*.ko
	$(foreach dir, drivers/gpu/drm drivers/virtio, \
		make -C $(KERNEL_DIR) \
			ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
			M=$(KERNEL_DIR)/$(dir) \
			modules -j$$(nproc); \
		find $(KERNEL_DIR)/$(dir) -type f -name "*.ko" \
			-exec cp {} $(OUT_MOD) \; ; \
	)
	rm $(SHARE_DIR)/*.ko
	cp $(OUT_MOD)/*.ko $(SHARE_DIR)

kernel:
	rm $(OUT)/Image
	make -C $(KERNEL_DIR) \
		ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
		Image -j$$(nproc)
	cp $(KERNEL_DIR)/arch/arm64/boot/Image $(OUT)/Image


run:
	qemu-system-aarch64 -M virt -cpu cortex-a72 -m 1G -smp 4 \
	  -kernel $(OUT)/Image \
	  -drive format=raw,file=$(OUT)/rootfs.img \
	  -append "root=/dev/vda rw" \
	  -fsdev local,security_model=passthrough,id=fsdev0,path=$(SHARE_DIR) \
	  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	  -device usb-ehci -device usb-mouse -device usb-kbd -usb \
	  -device virtio-gpu \
	  -serial stdio

run2:
	qemu-system-aarch64 -M virt -cpu cortex-a72 -m 1G -smp 4 \
	  -kernel $(OUT)/Image \
	  -drive format=raw,file=$(OUT)/rootfs.img \
	  -append "root=UUID=$$(blkid -o value -s UUID $(OUT)/rootfs.img) rw" \
	  -fsdev local,security_model=passthrough,id=fsdev0,path=$(SHARE_DIR) \
	  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	  -device virtio-gpu \
	  -serial stdio

