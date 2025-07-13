# 🛡️ RAMSAFE: RAM-based Secure Analysis Forensics Environment

<div align="center">
  <img src="ramsafe_wallpaper.ico" alt="RAMSAFE Icon">
</div>

🎯 **For a live USB Linux distribution designed for the National Child Protection Task Force (NCPTF)**, whose primary goal is to operate entirely in memory (RAM) to prevent any child sexual abuse material (CSAM) from being written to disk, and which includes tools to help interact with images for law enforcement.

⚠️ **Important Security Notice:** The tools in this toolset write to disk. When running within RAMSAFE, they will not write to a hard-drive but only to RAM. If you use the tools in this repository with a standard linux on a hard-drive they will write files to the disk. This means that if someone looks at that hard-drive these files may be found on them.

## ⚡ Quick User guide (I don't want to read the rest of the docs 😅)

1. 🛒 Purchase a USB drive of at least 8GB.
2. ⬇️ Download RAMSAFE from [Not Downloadable yet](https://ramsafe.org), 🔐 SHA256 hash of .iso is  `121167d6b7c5375cd898c717edd8cb289385367ef8aeda13bf4ed095b7065b0d` (This build guide works but there is not a site for storage. Contact NCPTF for a copy)
3. 🔌 Plug in USB drive,
4. 🔥 Use a tool like [RUFUS](https://rufus.ie/en/) if you are in Windows or Startup Disk Creator for Linux (this may require an install of new software in Ubuntu) to load the RAMSAFE.iso to USB.
5. 🔄 Reboot machine.
    1. ⌨️ While rebooting press the Boot time menu (F12 for Dell)
    2. 🖥️ Follow Prompts for keyboard and network.
    3. ❌ No need to update installer as you are not installing this os. **WARNING if you select install and follow though it will erase your hard-drive**
    4. ✅ Select try (no need to select install)
    5. 💻 This loads a whole new Operating system
    6. 🕵️ Help investigate CSAM perpetrators
    7. 📧 Send tips to law enforcement
    8. 🧠 While you work, all work is in memory so it is not kept and it does not write anything to disk
6. 🔄 Reboot machine.
7. 🔌 Remove USB.
8. ✅ Original operating system is untouched.

📝 **Note:** This will boot on most machines. It will not work on the newer Mac Machines that use the M series chips as they are ARM based.

## 📖 Full User Guide

Please go to the [User Guide](user_guide.md) 🛠️

## 🔨 Full Build Guide

Please go to the [Build Guide](build_guide.md) 📋
