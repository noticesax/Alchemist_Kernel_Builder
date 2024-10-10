# Alchemist Kernel Builder: Your ARM64 Kernel Brewery

Tired of generic kernels?  Want to brew your own custom Linux kernel for your ARM64 device?  Kernel Alchemist is here to help! This bash script simplifies the process of building a personalized kernel, tailored to your exact needs.

## Features

* **Defconfig Discovery:**  Easily browse and select from available kernel configurations (defconfigs) or whip up your own using the interactive menuconfig. No more searching through endless files!
* **Clang Conjuring:** Kernel Alchemist automatically summons the latest ZyC Clang 20.0.0 compiler, ensuring you have the finest tools for the job.  No manual downloads or installations needed!
* **Defconfig Alchemy:**  Regenerate existing defconfigs or tweak them to perfection with menuconfig.  Save your concoctions and reuse them later.
* **Telegram Telepathy:**  Get notified instantly on Telegram if your brewing process encounters any hiccups.  Debug and fix issues faster than ever before.
* **Lightweight and Brewtiful:**  Kernel Alchemist is a lean, mean, bash-scripting machine.  Easy to use, easy to customize.

## Ingredients (Prerequisites)

* **Linux Build Environment:** A system running a Linux distribution (e.g., Ubuntu) with basic build tools installed.
* **Essential Packages:** `bc`, `curl`, `make`, `zip`, `wget`, `git` (most likely already present on your system).
* **Telegram Bot:**  A Telegram bot created using BotFather. Obtain your bot token and the chat ID where you want to receive notifications.
* **AnyKernel3:** An AnyKernel3 repository for packaging your compiled kernel.
* **Defined Variables:**
    * **`TELEGRAM_BOT_TOKEN`**: Your Telegram bot token.
    * **`TELEGRAM_CHAT_ID`**: Your Telegram chat ID.
    * **`DEVICE_NAME`**: The codename of your device (e.g., merlinx, lancelot).
    * **`KERNEL_VERSION`**: The name of your kernel (e.g., Fearless, Atomic).
    * **`ARCH`**:  The architecture of your device (set to `arm64` by default).
    * **`PROCS`**: The number of CPU cores to use for compilation (set to `8` by default).
    * **`LINKER`**: The linker to use (set to `ld.lld` by default).

## Brewing Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/noticesax/Alchemist_Kernel_Builder.git
   
## Credit
This script is inspired by Origami Kernel Builder by @rem01gaming

## License

This script is licensed under the GNU General Public License v3.0. Refer to the [LICENSE](LICENSE) file for more details.
