#!/bin/bash

# --- User Configuration ---
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
DEVICE_NAME=""
KERNEL_VERSION=""
# --------------------------

# --- Script Configuration ---
ARCH=arm64
PROCS=8
LINKER=ld.lld
# --------------------------

# --- Color Variables ---
RED='\033[0;31m'
NOCOLOR='\033[0m'
LIGHTCYAN='\033[1;36m'
LIGHTGREEN='\033[1;32m'
# ----------------------

# --- Check for empty variables ---
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ] || [ -z "$DEVICE_NAME" ] || [ -z "$KERNEL_VERSION" ]; then
  echo -e "${RED}Error: Please fill all required variables.${NOCOLOR}"
  exit 1
fi

# --- Function to display and select defconfig ---
show_defconfigs() {
  local defconfig_path="./arch/${ARCH}/configs"
  if [ ! -d "$defconfig_path" ]; then
    echo -e "${RED}FATAL:${NOCOLOR} Invalid Kernel directory."
    exit 2
  fi
  echo -e "Available defconfigs:\n"
  local defconfigs=($(ls "$defconfig_path"))
  for ((i=0; i<${#defconfigs[@]}; i++)); do
    echo -e "${LIGHTCYAN}$i: ${defconfigs[i]}${NOCOLOR}"
  done
  echo ""
  read -p "Select the defconfig: " choice
  if [ "$choice" -ge 0 ] && [ "$choice" -lt ${#defconfigs[@]} ]; then
    DEFCONFIG="${defconfigs[choice]}"
    echo "Selected defconfig: $DEFCONFIG"
  else
    echo -e "${RED}Error:${NOCOLOR} Invalid choice."
    exit 1
  fi
}

# --- Function to regenerate defconfig ---
regen_defconfig() {
  show_defconfigs
  make O=out ARCH=${ARCH} ${DEFCONFIG}
  cp -rf ./out/.config ./arch/${ARCH}/configs/${DEFCONFIG}
  echo -e "${LIGHTGREEN}Defconfig ${DEFCONFIG} regenerated.${NOCOLOR}"
}

# --- Function to open menuconfig and save defconfig ---
open_menuconfig() {
  show_defconfigs
  make O=out ARCH=${ARCH} ${DEFCONFIG}
  echo -e "${LIGHTGREEN}Note: Save the config with name '.config'.${NOCOLOR}"
  make O=out menuconfig
  cp -rf ./out/.config ./arch/${ARCH}/configs/${DEFCONFIG}
  echo -e "${LIGHTGREEN}Defconfig ${DEFCONFIG} saved.${NOCOLOR}"
}

# --- Function to zip the kernel ---
zip_kernel() {
  local kernel_image="./out/arch/${ARCH}/boot/Image.gz-dtb"
  if [ ! -f "$kernel_image" ]; then
    kernel_image="./out/arch/${ARCH}/boot/Image.gz"
  fi

  cp "$kernel_image" ./AnyKernel3
  cd ./AnyKernel3

  # --- Generate zip file name ---
  build_date=$(date +%Y%m%d)
  build_number=$(date +%H%M)
  zip_name="${DEVICE_NAME}-${KERNEL_VERSION}-${build_date}-${build_number}.zip"

  # --- Zip the kernel ---
  zip -r9 "${zip_name}" * -x .git README.md *placeholder
  cd ..

  mkdir -p ./out/target
  rm -f ./AnyKernel3/Image.gz ./AnyKernel3/Image.gz-dtb
  mv ./AnyKernel3/"${zip_name}" ./out/target
}

# --- Function to send file to Telegram ---
send_to_telegram() {
  local file_path="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_CHAT_ID}" \
    -F document="@${file_path}" \
    -F caption="${KERNEL_VERSION} Successfully built!"
}

# --- Function to send error message to Telegram ---
send_error_message() {
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" \
    -F chat_id="${TELEGRAM_CHAT_ID}" \
    -F document="@./out/build.log" \
    -F caption="An error occurred during compilation. Please check the build log."
}

# --- Function to send start message to Telegram ---
send_start_message() {
  local message="
  Kernel compilation started for ${DEVICE_NAME} with version ${KERNEL_VERSION}.
  "
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${message}"
}

# --- Function to compile the kernel ---
compile_kernel() {
  # Install necessary packages
  for pkg in bc curl make zip wget git; do
    if ! command -v "$pkg" &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y "$pkg"
    fi
  done

  # Clone Clang if not exists
  if [ ! -d "${PWD}/clang" ]; then
    echo "Cloning clang..."
    latest_release_url=$(curl -s "https://api.github.com/repos/ZyCromerZ/Clang/releases/latest" | grep '"browser_download_url":' | cut -d '"' -f 4)
    wget "$latest_release_url" -O "clang.tar.gz"
    rm -rf clang && mkdir clang && tar -xvf clang.tar.gz -C clang && rm -rf clang.tar.gz
    echo "clang cloned!"
  else
    echo "The clang folder already exists."
  fi

  # Clone AnyKernel3 if not exists
  if [ ! -d "AnyKernel3" ]; then
    echo "AnyKernel3 folder not found."
    read -p "Enter the AnyKernel3 repository URL: " ANYKERNEL_URL
    git clone "$ANYKERNEL_URL" AnyKernel3
    echo "AnyKernel3 cloned!"
  else
    echo "AnyKernel3 folder already exists."
  fi

  rm -rf ./out/arch/${ARCH}/boot/Image.gz-dtb 2>/dev/null

  # Set environment variables
  export KBUILD_BUILD_USER="${BUILDER}"
  export KBUILD_BUILD_HOST="${BUILD_HOST}"
  export LOCALVERSION="-${DEVICE_NAME}-${KERNEL_VERSION}"
  export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
  export CROSS_COMPILE_COMPAT="arm-linux-gnueabi-"
  export CROSS_COMPILE="aarch64-linux-gnu-"
  export PATH="${PWD}/clang/bin:${PATH}"

  # Call the show_defconfigs function
  show_defconfigs

  make O=out ARCH=${ARCH} ${DEFCONFIG}

  # Send start message to Telegram
  send_start_message

  START=$(date +"%s")

  # Compile the kernel and check for errors
  if ! make -j"$PROCS" O=out \
    ARCH=${ARCH} \
    LD="${LINKER}" \
    AR=llvm-ar \
    AS=llvm-as \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CC="clang" \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabihf- \
    CONFIG_NO_ERROR_ON_MISMATCH=y \
    CONFIG_DEBUG_SECTION_MISMATCH=y \
    V=0 2>&1 | tee out/build.log; then

    # Send error message with build log to Telegram
    send_error_message

  else
    END=$(date +"%s")
    DIFF=$((END - START))
    export minutes=$((DIFF / 60))
    export seconds=$((DIFF % 60))

    # Zip the kernel
    zip_kernel

    # Send the kernel to Telegram
    send_to_telegram "./out/target/${zip_name}"
  fi
}

# --- Display option menu ---
echo -e "
${LIGHTCYAN}Kernel Build Script${NOCOLOR}

1. Regenerate defconfig
2. Open menuconfig
3. Compile kernel
4. Exit
"

read -p "Choose an option: " option

case $option in
  1) regen_defconfig ;;
  2) open_menuconfig ;;
  3) compile_kernel ;;
  4) exit 0 ;;
  *) echo -e "${RED}Invalid option.${NOCOLOR}" ;;
esac
