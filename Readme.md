使用 qemu 调试 linux + drm/libdrm 的编译和配置脚本。

文件目录

```bash
$ tree -L 1
.
├── apps
├── build # 本仓库的所在路径
├── buildroot
├── busybox
├── gnu-efi
├── libdrm
├── linux
├── linuxdrivers
└── u-boot
```

build 目录上传了一份编译好的结果，下载仓库后简单配置后，可以启动qemu、测试drm。

```bash
# in 'build' directory
qemu-img create out/rootfs.img 512m
mkfs.ext4 out/rootfs.img

mkdir out/rootfs
make mount
sudo cp -ra out/rootfs_tmplate/* out/rootfs
make umount

make run
```

