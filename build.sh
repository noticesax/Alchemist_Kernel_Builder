compile_kernel() {
    # Check if necessary packages are installed
    if ! command -v bc &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y bc
    fi
    if ! command -v curl &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y curl
    fi
    if ! command -v make &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y make
    fi
    if ! command -v zip &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y zip
    fi

    rm ./out/arch/${ARCH}/boot/Image.gz-dtb 2>/dev/null

    export KBUILD_BUILD_USER=${BUILDER}
    export KBUILD_BUILD_HOST=${BUILD_HOST}
    export LOCALVERSION=${localversion}
    export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
    export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
    export CROSS_COMPILE="aarch64-linux-gnu-"

    # Meminta input defconfig
    read -p "Masukkan defconfig (contoh: defconfig, vendor/defconfig, dll.): " DEFCONFIG

    make O=out ARCH=${ARCH} ${DEFCONFIG}

    START=$(date +"%s")

    make -j"$PROCS" O=out \
        ARCH=${ARCH} \
        LD="${LINKER}" \
        AR=llvm-ar \
        AS=llvm-as \
        NM=llvm-nm \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CC="clang" \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabihf- \
        CONFIG_NO_ERROR_ON_MISMATCH=y \
        CONFIG_DEBUG_SECTION_MISMATCH=y \
        V=0 2>&1 | tee out/build.log

    END=$(date +"%s")
    DIFF=$((END - START))
    export minutes=$((DIFF / 60))
    export seconds=$((DIFF % 60))

    # Check for errors in the build log
    if grep -q "error:" out/build.log; then
        # Zip the build log
        zip -r out/error.log.zip out/build.log

        # Meminta input bot token dan chat ID
        read -p "Masukkan Bot Token Telegram: " BOT_TOKEN
        read -p "Masukkan Chat ID Telegram: " CHAT_ID

        # Send the zipped log to Telegram
        curl -F "chat_id=${CHAT_ID}" -F "document=@out/error.log.zip" "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument"
    fi
}
