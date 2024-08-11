#!/bin/sh
insmod /mnt/drm_shmem_helper.ko
insmod /mnt/virtio_dma_buf.ko
insmod /mnt/virtio-gpu.ko

echo "loading virtio-gpu ko success"
