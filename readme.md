#  RAMSAFE: RAM-based Secure Analysis Forensics Environment
![RAMSAFE Icon](ramsafe_icon.png){width=128 height=128}
For a live USB Linux distribution designed for the National Child Protection Task Force (NCPTF), whose primary goal is to operate entirely in memory (RAM) to prevent any child sexual abuse material (CSAM) from being written to disk, and which includes tools to help interact with images for law enforcement.<br>
The tools in this toolset write to disk. When running within RAMSAFE, they will not write to a hard-drive but only to RAM. If you use the tools in this repository with a standard linux on a hard-drive they will write files to the disk. This means that if somone looks at that hard-drive these files may be found on them. 

## Quick User guide ( I don't want to read the docs)
1. Purchase a USB drive of at least 64GB.
2. Download RAMSAFE from here
3. Use a tool like RUFUS (Windows) or Live CD Creator (Linux) to load RAMSAFE .iso to USB
4. Plug USB drive 
6. Reboot machine.
- While rebooting press the Boot time menu (F12 for Dell)
- This loads a whole new Operating system
- Help investigate CSAM perpetrators
- Send tips to law enforcement
- While you work, all work is in memory so it is not kept and it does not write anything to disk
7. Reboot
8. Remove USB
9. Original Operating system is untouched. 

Note: This will work on most machines. It will not work on the newer Mac Machines that use the M series Chips as they are ARM based.

## Full User Guide
Please go to the [User Guide](user_guide.md)

## Full Build Guide
Please go to the [Build Guide](build_guide.md)