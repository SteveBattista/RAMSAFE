# 🛡️ RAMSAFE (RAM-based Secure Analysis Forensics Environment) Build Guide

If you are interested in the user guide please go to the [User Guide](user_guide.md) 📖

## 🔨 Build Guide

1. 🖥️ An Ubuntu Desktop System is required to build a RAMSAFE .ISO (Tested on 24.02.02 LTS)
    - 💻 Recommend a minimum of 2 cores, 4GB memory and 50 GB of space for the operating system to build this image.
    - 💿 ISO created is about 5.6 GB

2. ⬇️ Download an Ubuntu Desktop into your Ubuntu installation from here [Ubuntu Desktop](https://ubuntu.com/download/desktop)

3. 🖥️ Run the following command in a terminal:

    ```bash
    sudo apt-add-repository universe
    sudo apt-add-repository ppa:cubic-wizard/release
    sudo apt update
    sudo apt install --no-install-recommends cubic
    ```

    📋 Additional instructions can be found at the [Cubic instructions on GitHub](https://github.com/PJ-Singh-001/Cubic)

4. 🚀 Either select cubic by either
    - 🔍 pressing the Show Apps button on the bottom left, type cubic in the search bar then select cubic icon
    - 💻 or by running `cubic` in a terminal
    - 📖 General instructions on how to use cubic are located in [instructions](https://github.com/PJ-Singh-001/Cubic)

5. 📁 Select a directory to build ramsafe (I use ramsafe)

6. 🎯 Use downloaded Ubuntu desktop under the filename option and disk name to RAMSAFE

7. ⚙️ Press Next, Press Customize, Get to the virtual environment terminal and type the following

    ```bash
    sudo apt update && sudo apt upgrade -y && apt install git -y && mkdir /install && cd /install && git clone https://github.com/SteveBattista/RAMSAFE.git && cd RAMSAFE/bin && ./install_script.sh
    ```

    🔧 This will install all of the RAMSAFE specific items needed

8. ➡️ Select Next

9. 🥾 Select Boot

10. ✏️ Replace text "Try or install Ubuntu" with "Run RAMSAFE" from the grub.cfg selection.

11. ➡️ Select Next

12. ✅ Select Generate

13. 🔌 Plug in at least a 8GB USB

14. 🔥 Use a tool like [RUFUS](https://rufus.ie/en/) if you are in Windows or Startup Disk Creator for Linux (this may require an install of new software in Ubuntu) to load RAMSAFE .iso to a USB

15. 🎉 You now have a useable Live USB item! 🚀

Note: If you make a new iso, it won't have the same hash as the default downloaded one. Therefore if you are going to check the hash you need to check against your new hash for changes.
