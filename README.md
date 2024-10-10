# Kernel Compiler

This bash script automates the kernel compilation process with additional features for error handling and reporting via Telegram.

## Features

- **Dependency installation:** Installs necessary packages (`bc`, `curl`, `make`, `zip`) if they are not already present.
- **Kernel compilation:** Compiles the kernel with the specified configuration.
- **Error handling:** Detects errors during compilation and sends the error log to Telegram.
- **Telegram reporting:** Sends the zipped error log to a specified Telegram bot.

## Prerequisites

- Debian-based system (like Ubuntu)
- `sudo` access to install packages
- Telegram bot with token and chat ID

## Usage

1.  **Configuration:**
    -   Adjust the `ARCH`, `DEFCONFIG`, `BUILDER`, `BUILD_HOST`, `localversion`, `LINKER`, and `PROCS` variables in the script according to your needs.
    -   Make sure you have the correct kernel configuration file (`DEFCONFIG`).
2.  **Run the script:**
    ```bash
    ./compile_kernel.sh
    ```
3.  **Enter Telegram information (if an error occurs):**
    -   If the script detects an error during compilation, you will be prompted to enter your Telegram bot token and chat ID.

## Notes

-   This script uses `apt-get` to install packages. If you are using a different Linux distribution, adjust the package installation commands accordingly.
-   Make sure your Telegram bot has permission to send files.

## Disclaimer

This script is provided "as is" without any warranty. Use at your own risk.
