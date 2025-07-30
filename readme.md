# 🛡️ RAMSAFE: RAM-based Secure Analysis Forensics Environment

<div align="center">
  <img src="ramsafe_wallpaper.ico" alt="RAMSAFE Icon">
</div>

🎯 **For a live USB Linux distribution designed for the National Child Protection Task Force (NCPTF)**, whose primary goal is to operate entirely in memory (RAM) to prevent any child sexual abuse material (CSAM) from being written to disk, and which includes tools to help interact with images for law enforcement.

⚠️ **Important Security Notice:** The tools in this toolset write to disk. When running within RAMSAFE, they will not write to a hard-drive but only to RAM. If you use the tools in this repository with a standard linux on a hard-drive they will write files to the disk. This means that if someone looks at that hard-drive these files may be found on them.

## 🚀 If using pre-constructed ramsafe.iso and you need to make a bootable USB

1. 🛒 Purchase a USB drive of at least 8GB.
2. ⬇️ Download RAMSAFE from [Not Downloadable yet](https://ramsafe.org), 🔐 SHA256 hash of .iso is  `803021389377e32d40125b1f80c785f79ea5244b2c24d43224e33c579866c244` (This build guide works but there is not a site for storage. Contact NCPTF for a copy)
3. 🔐 Check the hash of the .iso to make sure it matches the expected value:

**For Linux/macOS (bash):**

Option 1 - Use the verification script:

```bash
# Run the verification script (replace with your actual ISO path)
./bin/verify_iso.sh ~/Downloads/ramsafe.iso
```

Option 2 - Manual verification:

```bash
echo "Expected: 803021389377e32d40125b1f80c785f79ea5244b2c24d43224e33c579866c244"
CALCULATED=$(sha256sum ramsafe.iso | cut -d' ' -f1)
echo "Calculated: $CALCULATED"
if [ "$CALCULATED" = "803021389377e32d40125b1f80c785f79ea5244b2c24d43224e33c579866c244" ]; then
    echo "✅ VERIFICATION PASSED - ISO is authentic"
else
    echo "❌ VERIFICATION FAILED - DO NOT USE THIS ISO"
fi
```

**For Windows (PowerShell):**

Option 1 - Use the verification script:

```powershell
# Run the verification script (replace with your actual ISO path)
.\bin\verify_iso.ps1 "C:\Downloads\ramsafe.iso"
```

N.B. You might need to run the following to run a powershell script

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Option 2 - Manual verification:

```powershell
$expected = "803021389377e32d40125b1f80c785f79ea5244b2c24d43224e33c579866c244"
$calculated = (Get-FileHash "ramsafe.iso").Hash.ToLower()
Write-Host "Expected: $expected"
Write-Host "Calculated: $calculated"
if ($calculated -eq $expected) {
    Write-Host "✅ VERIFICATION PASSED - ISO is authentic" -ForegroundColor Green
} else {
    Write-Host "❌ VERIFICATION FAILED - DO NOT USE THIS ISO" -ForegroundColor Red
}
```

## ⚡ Quick user guide (I don't want to read all of the instructions 😅)

1. 🔌 Plug in USB drive.
2. 🔥 Use a tool like [RUFUS](https://rufus.ie/en/) if you are in Windows or Startup Disk Creator for Linux (this may require an install of new software in Ubuntu) to load the RAMSAFE.iso to USB.
3. 🔄 Reboot machine.
    1. ⌨️ While rebooting press the Boot time menu (F12 for Dell)
    2. 🖥️ Follow Prompts for keyboard and network.
    3. ❌ No need to update installer as you are not installing this os. **WARNING if you select install and follow though it will erase your hard-drive**
    4. ✅ Select try (no need to select install)
    5. 💻 This loads a whole new Operating system
    6. 🕵️ Help investigate CSAM perpetrators
    7. 📧 Send tips to law enforcement
    8. 🧠 While you work, all work is in memory so it is not kept and it does not write anything to disk
4. 🔄 Reboot machine.
5. 🔌 Remove USB.
6. ✅ Original operating system is untouched.

📝 **Note:** This will boot on most machines. It will not work on the newer Mac Machines that use the M series chips as they are ARM based.

## 📖 Full User Guide

Please go to the [User Guide](user_guide.md) 🛠️

## 🔨 Full Build Guide

Please go to the [Build Guide](build_guide.md) 📋
