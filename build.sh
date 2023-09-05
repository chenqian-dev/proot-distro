#! /bin/bash
set -e

# 外部定义 当前仅做测试
PACKAGE_NAME=com.qiniu.upd.test
ACCESS_KEY="DkawmEAF0x70rZEq4sTmZGVzGTPNmgwjy4KxhFXu"
SECRET_KEY="0AtWHtEIQ3Skne6nzC8u5BYAtk05d1xDjS6vJr7e"

# 内部存储使用
PROOT_DISTRO_MD5=""

# 准备编译目录
prepare(){
    echo '======================= 准备开始 ======================='
    echo $PWD
    # 删除编译目录
    rm -rf build
    mkdir -p build/proot-distro
    cp proot-distro-3.13.0.tar.gz build/proot-distro/proot-distro-3.13.0.tar.gz
    mkdir -p build/bootstrap
    cp termux-packages.zip build/bootstrap/termux-packages.zip
    # 下载 qshell
    mkdir -p build/qshell
    wget -P build/qshell https://github.com/qiniu/qshell/releases/download/v2.12.0/qshell-v2.12.0-linux-amd64.tar.gz
    tar -xzvf build/qshell/qshell-v2.12.0-linux-amd64.tar.gz -C build/qshell
    chmod +x build/qshell/qshell
    echo '======================= 准备结束 ======================='
}

# 处理 proot-distro
process_proot_distro(){
    echo '======================= 处理 proot-distro 开始======================='
    cd build/proot-distro
    echo $PWD
    tar -xvf proot-distro-3.13.0.tar.gz
    sed -i "s/com.qiniu.upd.app/${PACKAGE_NAME}/g" distro-plugins/debian.sh
    rm proot-distro-3.13.0.tar.gz
    tar -czf proot-distro-3.13.0.tar.gz .
    # 记录 md5
    PROOT_DISTRO_MD5=$(md5sum ./proot-distro-3.13.0.tar.gz | awk '{print $1}')
    echo "proot-distro md5: $PROOT_DISTRO_MD5"
    # TODO 上传到对应的 KODO 文件夹
    ./../qshell/qshell account --overwrite $ACCESS_KEY $SECRET_KEY phelps
    ./../qshell/qshell rput --overwrite "sdk-release" "termux/$PACKAGE_NAME/proot-distro-3.13.0.tar.gz" $(realpath "./proot-distro-3.13.0.tar.gz")
    cd ../..
    echo $PWD
    echo '======================= 处理 proot-distro 结束======================='
}

# 处理 bootstrap
process_bootstrap(){
    echo '======================= 处理 bootstrap 开始 ======================='
    cd build/bootstrap
    echo $PWD
    unzip termux-packages.zip
    chmod -R 777 termux-packages
    cd termux-packages
    # TODO 处理 proot-distro 的 MD5
    sed -i "7s/.*/TERMUX_PKG_SHA256=$PROOT_DISTRO_MD5/" 'packages/proot-distro/build.sh'
    # 处理包名变更
    sed -i "s/com.qiniu.upd.app/${PACKAGE_NAME}/g" `grep com.qiniu.upd.app -rl ./`
    # 修改 docker 脚本为直接编译
    # sed -i '71s|$| -C '\''./scripts/build-bootstraps.sh'\''|' scripts/run-docker.sh
    # sed -i '73s|$| -C '\''./scripts/build-bootstraps.sh'\''|' scripts/run-docker.sh
    cd ../../..
    echo $PWD
    echo '======================= 处理 bootstrap 结束 ======================='
}

build_bootstrap(){
    echo '======================= 编译 bootstrap 开始 ======================='
    cd build/bootstrap/termux-packages/scripts
    echo $PWD
    chmod +x ./run-docker.sh
    ./run-docker.sh
    exit
    # TODO 上传文件到 KODO
    ./../qshell/qshell account --overwrite $ACCESS_KEY $SECRET_KEY phelps
    ./../qshell/qshell rput --overwrite "sdk-release" "termux/$PACKAGE_NAME/bootstrap-aarch64.zip" $(realpath "./bootstrap-aarch64.zip")
    cd ../../../..
    echo '======================= 编译 bootstrap 结束 ======================='
}

build(){
    prepare
    process_proot_distro
    process_bootstrap
    build_bootstrap
}

build