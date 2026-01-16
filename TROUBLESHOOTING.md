# 🔧 RAMSAFE Troubleshooting Guide

This guide provides solutions to common problems encountered when using RAMSAFE and its forensic analysis tools.

## 📋 Table of Contents

- [Installation and Setup Issues](#installation-and-setup-issues)
- [Script Execution Problems](#script-execution-problems)  
- [Input Validation Errors](#input-validation-errors)
- [Network and Download Issues](#network-and-download-issues)
- [File Access Problems](#file-access-problems)
- [Hash Verification Issues](#hash-verification-issues)
- [Dependency Problems](#dependency-problems)
- [Performance Issues](#performance-issues)
- [Error Code Reference](#error-code-reference)
- [Advanced Troubleshooting](#advanced-troubleshooting)

---

## 🚀 Installation and Setup Issues

### Issue: "RAMSAFE won't boot from USB"
**Symptoms:** USB doesn't appear in boot menu or system boots to regular OS
**Solutions:**
1. **Check BIOS/UEFI Settings:**
   ```
   - Enable Legacy Boot or CSM mode
   - Disable Secure Boot temporarily
   - Set USB as first boot priority
   ```

2. **USB Drive Issues:**
   ```
   - Use a different USB port (prefer USB 2.0)
   - Try a different USB drive (8GB+ recommended)
   - Re-flash the ISO using DD mode in Rufus
   ```

3. **ISO File Problems:**
   ```
   - Verify SHA256 hash: ./bin/verify_iso.sh ramsafe.iso
   - Re-download ISO if hash verification fails
   - Check ISO file isn't corrupted (size ~5.6GB)
   ```

### Issue: "Machine doesn't support RAMSAFE"
**Symptoms:** Boot fails or system crashes during startup
**Solutions:**
1. **Architecture Compatibility:**
   - RAMSAFE requires x86/x64 architecture
   - Apple M-series (ARM) processors are NOT supported
   - Check: `uname -m` should show x86_64 or similar

2. **Insufficient RAM:**
   - Minimum 4GB RAM required
   - Recommended 8GB+ for optimal performance
   - RAMSAFE loads entire system into memory

---

## 🖥️ Script Execution Problems

### Issue: "Permission denied" when running scripts
**Error Message:** `bash: ./summary_file.sh: Permission denied`
**Solutions:**
```bash
# Make scripts executable
chmod +x /home/complier/projects/tools/RAMSAFE/bin/*.sh

# Or run with bash explicitly
bash /home/complier/projects/tools/RAMSAFE/bin/summary_file.sh file.jpg
```

### Issue: Scripts show "command not found"
**Error Message:** `summary_file.sh: command not found`
**Solutions:**
```bash
# Add RAMSAFE bin directory to PATH
export PATH="/home/complier/projects/tools/RAMSAFE/bin:$PATH"

# Or use full path
/home/complier/projects/tools/RAMSAFE/bin/summary_file.sh file.jpg

# Or run from correct directory
cd /home/complier/projects/tools/RAMSAFE/bin
./summary_file.sh file.jpg
```

### Issue: "ramsafe_utils.sh not found"
**Error Message:** `source: ramsafe_utils.sh: No such file or directory`
**Solution:**
Ensure the utility library is in the same directory as the script:
```bash
ls -la /home/complier/projects/tools/RAMSAFE/bin/ramsafe_utils.sh
# Should exist and be readable
```

---

## ⚠️ Input Validation Errors

### Issue: "File path too long"
**Error Code:** 8 (EXIT_SECURITY_VIOLATION)
**Error Message:** `File path too long (maximum 4096 characters)`
**Solution:**
- Use shorter file paths
- Move files to directories with shorter paths
- Use symbolic links if needed

### Issue: "File path contains null bytes"
**Error Code:** 8 (EXIT_SECURITY_VIOLATION)
**Error Message:** `File path contains null bytes`
**Solution:**
This indicates a potential security attack. Check your input source:
```bash
# Check for hidden characters
cat -A filename.txt
# Look for ^@ characters (null bytes)
```

### Issue: "Invalid URL format"
**Error Code:** 2 (EXIT_INVALID_ARGS)
**Error Message:** `Invalid URL format. Must start with http:// or https://`
**Solutions:**
```bash
# Correct formats
https://example.com/image.jpg
http://example.com/document.pdf

# Incorrect formats (will be rejected)
ftp://example.com/file.txt
file:///local/file.txt
example.com/image.jpg  # Missing protocol
```

### Issue: "URL contains potentially dangerous characters"
**Error Code:** 8 (EXIT_SECURITY_VIOLATION)
**Solutions:**
- Remove special shell characters: `$()` `{}` `;` `|` `&`
- URL encode special characters if legitimate
- Use quotes around URLs with spaces: `"https://example.com/file name.jpg"`

### Issue: "Access to localhost/private IPs is not allowed"
**Error Code:** 8 (EXIT_SECURITY_VIOLATION)
**Why:** Security measure to prevent SSRF attacks
**Blocked URLs:**
```
http://localhost/...
http://127.0.0.1/...
http://192.168.x.x/...
http://10.x.x.x/...
http://172.16-31.x.x/...
```

---

## 🌐 Network and Download Issues

### Issue: "Failed to download file from URL"
**Error Code:** 5 (EXIT_NETWORK_ERROR)
**Solutions:**

1. **Check URL accessibility:**
```bash
# Test URL in browser first
# Or use curl to test
curl -I https://example.com/file.jpg
```

2. **Network connectivity:**
```bash
# Test internet connection
ping google.com

# Check DNS resolution
nslookup example.com
```

3. **URL-specific issues:**
```bash
# Try with different user agent
curl -H "User-Agent: Mozilla/5.0" https://example.com/file.jpg

# Check if site blocks automated requests
```

4. **Timeout issues:**
```bash
# Manually download with longer timeout
curl --max-time 600 -o file.jpg https://example.com/file.jpg
```

### Issue: "Download resulted in empty file"
**Error Code:** 5 (EXIT_NETWORK_ERROR)
**Solutions:**
1. Server returned empty response
2. URL might be incorrect (404 error)
3. Server might require authentication
4. Check URL in browser to verify it returns a file

---

## 📁 File Access Problems

### Issue: "File not found or not accessible"
**Error Code:** 3 (EXIT_FILE_NOT_FOUND)
**Solutions:**

1. **Check file exists:**
```bash
ls -la /path/to/file.jpg
# Should show file details
```

2. **Check file permissions:**
```bash
# Make file readable
chmod 644 /path/to/file.jpg

# Check current permissions
stat -c "%a %n" /path/to/file.jpg
```

3. **Path issues:**
```bash
# Use absolute path instead of relative
/home/user/Documents/file.jpg  # Good
~/Documents/file.jpg           # Good  
../files/file.jpg              # May cause issues
```

### Issue: "File not readable"
**Error Code:** 4 (EXIT_PERMISSION_DENIED)
**Solutions:**
```bash
# Fix file permissions
chmod 644 file.jpg

# Check if you own the file
ls -la file.jpg

# If owned by root, copy to your directory
cp /root/evidence.jpg ~/evidence.jpg
```

### Issue: "File too large"
**Error Code:** 7 (EXIT_VALIDATION_FAILED)
**Error Message:** `File too large: X bytes (maximum 1073741824 bytes)`
**Solutions:**
- Maximum file size is 1GB for security reasons
- For larger files, use specialized forensic tools
- Consider file splitting if analysis is needed

---

## 🔐 Hash Verification Issues

### Issue: "Invalid hash format"
**Error Code:** 2 (EXIT_INVALID_ARGS)
**Common Problems:**

1. **Wrong hash length:**
```bash
# MD5: 32 hex characters
d41d8cd98f00b204e9800998ecf8427e

# SHA1: 40 hex characters  
da39a3ee5e6b4b0d3255bfef95601890afd80709

# SHA256: 64 hex characters
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

# SHA512: 128 hex characters
cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e
```

2. **Invalid characters:**
```bash
# Only hexadecimal characters allowed: 0-9, a-f, A-F
# These are INVALID:
abc123-def456  # Contains dash
abc123 def456  # Contains space
abcghi123456   # Contains 'g', 'h', 'i'
```

### Issue: "Hash verification failed"
**Error Code:** 7 (EXIT_VALIDATION_FAILED)
**Solutions:**

1. **File corruption:**
```bash
# Re-download the file
# Check download integrity
curl -L https://example.com/file.iso > file.iso
sha256sum file.iso
```

2. **Wrong expected hash:**
```bash
# Double-check expected hash from official source
# Calculate current hash
sha256sum your_file.iso

# Compare with official hash
```

3. **File modification:**
- File may have been modified after hash was calculated
- Check file timestamps
- Verify download source is authentic

---

## 🔧 Dependency Problems

### Issue: "Required dependency not found"
**Error Code:** 6 (EXIT_DEPENDENCY_MISSING)

**Missing jq:**
```bash
# Ubuntu/Debian
sudo apt install jq

# CentOS/RHEL
sudo yum install jq

# macOS
brew install jq
```

**Missing ssdeep:**
```bash
# Ubuntu/Debian
sudo apt install ssdeep

# CentOS/RHEL
sudo yum install ssdeep

# macOS
brew install ssdeep
```

**Missing exiftool:**
```bash
# Ubuntu/Debian
sudo apt install exiftool

# CentOS/RHEL
sudo yum install perl-Image-ExifTool

# macOS
brew install exiftool
```

**Missing curl:**
```bash
# Ubuntu/Debian (usually pre-installed)
sudo apt install curl

# CentOS/RHEL
sudo yum install curl

# macOS (usually pre-installed)
brew install curl
```

---

## 🐌 Performance Issues

### Issue: Scripts are slow for large files
**Solutions:**

1. **Expected behavior:**
- Hash calculation is CPU-intensive
- Larger files naturally take longer
- 100MB file: ~10-30 seconds
- 1GB file: ~2-5 minutes

2. **System optimization:**
```bash
# Check available memory
free -h

# Check CPU usage
top

# Close unnecessary applications
```

3. **Alternative approaches:**
```bash
# For very large files, consider partial hashing
head -c 1M largefile.bin | sha256sum

# Or use faster hash algorithms for initial checks
md5sum largefile.bin  # Faster than SHA256
```

### Issue: Out of memory errors
**Solutions:**
1. Increase available RAM
2. Close other applications
3. Process smaller files
4. Use system with more memory

---

## 📊 Error Code Reference

| Code | Constant | Meaning | Common Causes |
|------|----------|---------|---------------|
| 0 | EXIT_SUCCESS | Success | Operation completed normally |
| 1 | EXIT_GENERAL_ERROR | General error | Unexpected failure |
| 2 | EXIT_INVALID_ARGS | Invalid arguments | Wrong parameters, malformed input |
| 3 | EXIT_FILE_NOT_FOUND | File not found | Missing file, wrong path |
| 4 | EXIT_PERMISSION_DENIED | Permission denied | Insufficient file permissions |
| 5 | EXIT_NETWORK_ERROR | Network error | Download failed, connection timeout |
| 6 | EXIT_DEPENDENCY_MISSING | Dependency missing | Required tool not installed |
| 7 | EXIT_VALIDATION_FAILED | Validation failed | Hash mismatch, file too large |
| 8 | EXIT_SECURITY_VIOLATION | Security violation | Dangerous input detected |

---

## 🔍 Advanced Troubleshooting

### Enable Debug Logging
```bash
# Set debug log level for detailed output
export RAMSAFE_LOG_LEVEL=4

# Run script with debug information
./summary_file.sh evidence.jpg
```

### Check Script Dependencies
```bash
# List all dependencies for a script
grep -n "check_dependencies\|command -v" bin/summary_file.sh

# Verify all required tools are available
which jq ssdeep exiftool curl sha256sum
```

### Test Utility Functions
```bash
# Run unit tests to verify utility functions
cd tests
./run_tests.sh --verbose

# Test specific functionality
bats test_ramsafe_utils.bats
```

### Manual Script Testing
```bash
# Test input validation
echo "Testing file validation:"
bash -c "source bin/ramsafe_utils.sh; validate_file_path 'nonexistent.txt'"

# Test URL validation  
echo "Testing URL validation:"
bash -c "source bin/ramsafe_utils.sh; validate_url 'https://example.com/test.jpg'"
```

### System Information for Bug Reports
```bash
# Collect system information
echo "System Information:"
uname -a
cat /etc/os-release
df -h
free -h

echo "RAMSAFE Environment:"
ls -la bin/
echo $PATH
which bash jq curl ssdeep exiftool
```

---

## 🆘 Getting Help

If you encounter issues not covered in this guide:

1. **Check Error Code:** Use the reference table above
2. **Enable Debug Logging:** Set `RAMSAFE_LOG_LEVEL=4`
3. **Run Tests:** Use `tests/run_tests.sh` to verify setup
4. **Collect Information:** Note exact error messages, system info, steps to reproduce
5. **Consult Documentation:** Review [User Guide](user_guide.md) and [Build Guide](build_guide.md)

### For Law Enforcement Support
Contact your IT department or the NCPTF technical team with:
- Exact error message
- System information (`uname -a`)
- Steps to reproduce the issue
- Any debug log output

---

## 💡 Prevention Tips

1. **Regular Updates:** Keep RAMSAFE tools updated
2. **System Maintenance:** Ensure adequate RAM and disk space
3. **Input Validation:** Always verify URLs and file paths before processing
4. **Test Environment:** Run tests after any system changes
5. **Backup Procedures:** Maintain copies of important evidence files

---

*This troubleshooting guide is part of the RAMSAFE forensic analysis toolkit. For additional support, consult your organization's IT department or forensic analysis team.*