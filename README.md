#  Alchemist Kernel Builder: Your ARM64 Kernel Brewery

Tired of generic kernels?  Want to brew your own custom Linux kernel for your ARM64 device?  Kernel Alchemist is here to help! This bash script simplifies the process of building a personalized kernel, tailored to your exact needs.

## Features

* **Defconfig Discovery:**  Easily browse and select from available kernel configurations (defconfigs) or whip up your own using the interactive menuconfig. No more searching through endless files!
* **Clang Conjuring:** Kernel Crafter automatically summons the latest ZyC Clang 20.0.0 compiler, ensuring you have the finest tools for the job.  No manual downloads or installations needed!
* **Defconfig Alchemy:**  Regenerate existing defconfigs or tweak them to perfection with menuconfig.  Save your concoctions and reuse them later.
* **Telegram Telepathy:**  Get notified instantly on Telegram if your brewing process encounters any hiccups.  Debug and fix issues faster than ever before.
* **Lightweight and Brewtiful:**  Kernel Crafter is a lean, mean, bash-scripting machine.  Easy to use, easy to customize.

## Ingredients (Prerequisites)

* A sprinkle of essential packages (`bc`, `curl`, `make`, `zip`, `wget`)
* A dash of defined variables: `ARCH`, `PROCS`, `BUILDER`, `BUILD_HOST`, `localversion`, and `LINKER`.
* A thirst for a custom kernel!

## Brewing Instructions

1.  Clone this repository: `git clone https://github.com/noticesax/Alchemist_Kernel_Builder.git`
2.  Gather your ingredients (see Prerequisites).
3.  Fire up the script: `cd Alchemist_kernel_Builder && chmod 0777 .craft sh && ./craft.sh`
4.  Follow the on-screen instructions to select your desired defconfig and brewing options.

## Secret Recipes (Example Usage)

```bash
./craft.sh
```

## Credits
This script is inspired by Origami Kernel Builder aka @rem01Gaming
