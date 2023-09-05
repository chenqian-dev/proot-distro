# termux-packages 编译

## 1. proot-distro

1. 解压当前目录下的 proot-distro-3.13.0.tar.gz
2. 修改 distro-plugins/debian.sh 中的 `TARBALL_URL['arch']` 中的地址为对应的 app 私有 data 目录，如 aarch64 为： `/data/data/包名/files/home/debian-aarch64-pd-v3.12.1.tar.xz`
3. 重新压缩当前的 proot-distro， `tar -czf proot-distro-3.13.0.tar.gz -C ./proot-distro-3.13.0 .`
4. 并上传到到对应的 kodo 文件目录：`sdk-release/termux/包名/proot-distro-3.13.0.tar.gz`，后续 termux-packages 的编译需要从这个地址下载

## termux-bootstrap

> [!CAUTION]  
> - 必须要先编译 proot-distro  
> - 如果包名变动，需要执行 `clean.sh`，整个重新编译  
> - 编译过程中如果找不到对应 package 的下载路径，则需要自己 google 查找并更新可用版本  
> - 编译过程中遇到 package 的 sha256 不相等的情况，则修改对应 package 的 `TERMUX_PKG_SHA256` 为对应的值即可

1. 解压当前目录下的 termux-packages.zip
2. 修改 `script/properties.sh` 中的 `TERMUX_APP_PACKAGE` 和 `TERMUX_REPO_PACKAGE` 为需要编译的 app 的包名
3. 运行 `script/run_docker.sh` 准备编译环境
4. 在 docker 中执行 `clean.sh`，注意，这个行为很耗时，只有当包名变化的时候才执行；如果仅需要重新编译其中某个包，只需要删除 `/data/data/.built-packages/package名` 即可
4. 在 docker 中执行 `script/build-bootstraps.sh`
5. 编译完成后会在主目录下生成 `bootstrap-arch.zip`
6. 上传 bootstrap-arch.zip 到 `sdk-release/termux/包名/bootstrap-arch.zip`