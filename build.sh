#!/bin/bash

# Definisikan variabel warna
RED='\033[0;31m'
NOCOLOR='\033[0m'
LIGHTCYAN='\033[1;36m'

# Pastikan variabel ARCH, PROCS, BUILDER, BUILD_HOST, localversion, dan LINKER sudah didefinisikan
# Contoh:
export ARCH=arm64
export PROCS=8
export BUILDER="your_username"
export BUILD_HOST="your_hostname"
export localversion="-test"
export LINKER="ld.lld"

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
    if ! command -v wget &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y wget
    fi

    # Check if clang folder exists
    if [ ! -d "${PWD}/clang" ]; then
        echo "Cloning clang..."

        # Get the latest release URL
        latest_release_url=$(curl -s "https://api.github.com/repos/ZyCromerZ/Clang/releases/latest" | grep '"browser_download_url":' | cut -d '"' -f 4)

        # Download the latest release assets
        wget "$latest_release_url" -O "clang.tar.gz"

        # Extract archive and clean it
        rm -rf clang && mkdir clang && tar -xvf clang.tar.gz -C clang && rm -rf clang.tar.gz
        echo "clang cloned!"
    else
        echo "The clang folder already exists."
    fi

    rm -rf ./out/arch/${ARCH}/boot/Image.gz-dtb 2>/dev/null

    export KBUILD_BUILD_USER=${BUILDER}
    export KBUILD_BUILD_HOST=${BUILD_HOST}
    export LOCALVERSION=${localversion}
    export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
    export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
    export CROSS_COMPILE="aarch64-linux-gnu-"
    export PATH="$PATH:$(pwd)/clang/bin"

    # Memanggil fungsi show_defconfigs
    show_defconfigs

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

show_defconfigs() {
    local defconfig_path="./arch/${ARCH}/configs"

    # Check if folder exists
    if [ ! -d "$defconfig_path" ]; then
        echo -e "${RED}FATAL:${NOCOLOR} Seems not a valid Kernel linux"
        exit 2
    fi

    echo -e "Available defconfigs:\n"

    # List defconfigs and assign them to an array
    local defconfigs=($(ls "$defconfig_path"))

    # Display enumerated defconfigs
    for ((i=0; i<${#defconfigs[@]}; i++)); do
        echo -e "${LIGHTCYAN}$i: ${defconfigs[i]}${NOCOLOR}"
    done

    echo ""
    read -p "Select the defconfig you want to process: " choice

    # Check if the choice is within the range of files
    if [ "$choice" -ge 0 ] && [ "$choice" -lt ${#defconfigs[@]} ]; then
        DEFCONFIG="${defconfigs[choice]}"
        echo "Selected defconfig: $DEFCONFIG"
    else
        echo -e "${RED}error:${NOCOLOR} Invalid choice"
        exit 1
    fi
}

# Jalankan fungsi compile_kernel
compile_kernel
