# RAMSAFE: RAM-based Secure Analysis Forensics Environment

<div align="center">
  <img src="ramsafe_wallpaper.ico" alt="RAMSAFE Icon">
</div>
<br>

For a live USB Linux distribution designed for the National Child Protection Task Force (NCPTF), whose primary goal is to operate entirely in memory (RAM) to prevent any child sexual abuse material (CSAM) from being written to disk, and which includes tools to help interact with images for law enforcement.<br>
The tools in this toolset write to disk. When running within RAMSAFE, they will not write to a hard-drive but only to RAM. If you use the tools in this repository with a standard linux on a hard-drive they will write files to the disk. This means that if someone looks at that hard-drive these files may be found on them.

## Quick User guide ( I don't want to read the rest of the docs)

1. Purchase a USB drive of at least 8GB.
2. Download RAMSAFE from [Not Downloadable yet](https://ramsafe.org), SHA256 hash of .iso is <b> NOT READY YET </b> (This build guie works but there is not a site for storage. Contact NCPTF and ask them to contact me for a copy)
3. Plug in USB drive,
4. Use a tool like [RUFUS](https://rufus.ie/en/) if you are in Windows or Startup Disk Creator for Linux (this may require an install of new software in Ubuntu) to load the RAMSAFE.iso to USB.
5. Reboot machine.
    a. WWhile rebooting press the Boot time menu (F12 for Dell)
    b. Follow Prompts for keyboard and network.
    c. No need to update installer as you are not installing this os.
    d. Select try (no need to select install)
    e. This loads a whole new Operating system
    f. Help investigate CSAM perpetrators
    g. end tips to law enforcement
    h. While you work, all work is in memory so it is not kept and it does not write anything to disk
6. Reboot machine.
7. Remove USB.
8. Original operating system is untouched.

Note: This will work on most machines. It will not work on the newer Mac Machines that use the M series chips as they are ARM based.

## Full User Guide

Please go to the [User Guide](user_guide.md)

## Full Build Guide

Please go to the [Build Guide](build_guide.md)
