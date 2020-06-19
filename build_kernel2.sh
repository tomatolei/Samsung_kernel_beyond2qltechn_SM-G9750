#!/bin/bash

BUILD_CROSS_COMPILE=/home/tools/aarch64-linux-android-4.9/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=/home/tools/new/snapdragon/llvm-arm-toolchain-ship/8.0/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

export KBUILD_BUILD_USER=leilei
export KBUILD_BUILD_HOST=ubuntu
test -z "$ANDROID_VERSION" && ANDROID_VERSION=100000 # qwerty12


BUILD_TOP_DIR=$(dirname $(readlink -f $0))
read -p "是否清除上次编译?(N/y)" reply
case $reply in
    y | Y)
	echo "清除上次编译结果。。。"
	make mrproper
    rm -rf $BUILD_TOP_DIR/modules
    rm -rf $BUILD_TOP_DIR/dtb
    rm -rf dt.img
    ;;
*)
	echo "不清除上次编译结果。。。"  
    ;;
esac

OUT_DIR=out

[ -d ${OUT_DIR} ] && rm -rf ${OUT_DIR}
mkdir ${OUT_DIR}

START=$(date +%s)

export ANDROID_MAJOR_VERSION=q
make -j32 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE ANDROID_VERSION="$ANDROID_VERSION" beyond2qlte_chn_open_defconfig
make -j32 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE ANDROID_VERSION="$ANDROID_VERSION"

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "编译完成，消耗时间："
[ $E_MIN != 0 ] && printf "%d 分 " $E_MIN
printf "%d 秒\n" $E_SEC

cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
cp out/arch/arm64/boot/Image-dtb $(pwd)/arch/arm64/boot/Image-dtb
cp out/arch/arm64/boot/Image-dtb-hdr $(pwd)/arch/arm64/boot/Image-dtb-hdr

