# 📋 RAMSAFE Development Documentation

## 🏗️ Architecture Overview

RAMSAFE follows a modular architecture with shared utilities and standardized error handling:

```
RAMSAFE/
├── bin/                    # Executable scripts
│   ├── ramsafe_utils.sh   # Shared utility library
│   ├── summary_file.sh    # File analysis tool
│   ├── summary_url.sh     # URL analysis tool  
│   ├── verify_iso.sh      # ISO verification tool
│   ├── ssdeep_compare_*.sh # File comparison tools
│   └── install_script.sh  # System setup script
├── tests/                 # Test suite
│   ├── test_ramsafe_utils.bats
│   ├── test_scripts.bats
│   └── run_tests.sh
└── docs/                  # Documentation
    ├── TROUBLESHOOTING.md
    ├── user_guide.md
    └── build_guide.md
```

## 🔧 Utility Library (ramsafe_utils.sh)

All scripts source the shared utility library which provides:

### Input Validation Functions
- `validate_file_path()` - Secure file path validation
- `validate_url()` - URL format and security validation  
- `validate_hash()` - Hash format validation (MD5, SHA1, SHA256, SHA512)
- `validate_examiner_id()` - Examiner ID format validation

### Error Handling
- Standardized exit codes (0-8)
- `die()` function for consistent error reporting
- `check_dependency()` and `check_dependencies()` for tool verification

### Secure Operations
- `create_temp_file()` - Create secure temporary files (600 permissions)
- `secure_delete()` - Securely delete files using shred
- `secure_download()` - Download files with security checks

### Logging System
- Multiple log levels (ERROR, WARN, INFO, DEBUG)
- Timestamp-prefixed messages
- Configurable via `RAMSAFE_LOG_LEVEL` environment variable

## 🛡️ Security Features

### Input Sanitization
- Path length limits (4096 chars max)
- Null byte detection
- Directory traversal prevention  
- URL validation (HTTP/HTTPS only)
- Private IP blocking (localhost, RFC 1918)
- Dangerous character filtering

### File Operations
- Realpath resolution to prevent traversal attacks
- File size limits (1GB max)
- Permission checks before processing
- Secure temporary file creation
- Cryptographic verification

### Network Security
- User-Agent header standardization
- Protocol restrictions (HTTP/HTTPS only) 
- Timeout limits (300 seconds)
- File size limits during download
- Redirect protocol enforcement

## 📊 Exit Code Standards

| Code | Constant | Usage |
|------|----------|-------|
| 0 | EXIT_SUCCESS | Successful completion |
| 1 | EXIT_GENERAL_ERROR | Unexpected errors |
| 2 | EXIT_INVALID_ARGS | Invalid command arguments |
| 3 | EXIT_FILE_NOT_FOUND | File does not exist |
| 4 | EXIT_PERMISSION_DENIED | Insufficient permissions |
| 5 | EXIT_NETWORK_ERROR | Download/network failures |
| 6 | EXIT_DEPENDENCY_MISSING | Required tools missing |
| 7 | EXIT_VALIDATION_FAILED | Hash verification failed |
| 8 | EXIT_SECURITY_VIOLATION | Dangerous input detected |

## 🧪 Testing Framework

### Test Structure
- **Unit Tests** (`test_ramsafe_utils.bats`): Test individual utility functions
- **Integration Tests** (`test_scripts.bats`): Test complete script workflows
- **Test Runner** (`run_tests.sh`): Automated test execution

### Running Tests
```bash
# Run all tests
./tests/run_tests.sh

# Install bats if needed
./tests/run_tests.sh --install-bats

# Verbose output
./tests/run_tests.sh --verbose
```

### Test Coverage
- Input validation (file paths, URLs, hashes)
- Error handling and exit codes
- Security violation detection
- Dependency checking
- File operations
- Network operations

## 🔍 Code Style Guidelines

### Script Headers
All scripts must include:
```bash
#!/bin/bash
#
# Script Name
# 
# Brief description of functionality
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Specific purpose
# USAGE: ./script.sh [options] <args>
```

### Error Handling
```bash
# Always source utility library first
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Use die() for errors
die $EXIT_INVALID_ARGS "Invalid input provided"

# Check dependencies
check_dependencies "jq" "curl" "ssdeep"

# Validate inputs
validated_path=$(validate_file_path "$input_file")
validated_url=$(validate_url "$input_url")
```

### Logging
```bash
# Use structured logging
log_info "Processing file: $filename"
log_error "Failed to process: $error_message"
log_debug "Debug information for developers"
```

### Security
```bash
# Always validate user input
validate_file_path "$user_input"
validate_url "$user_url"

# Use secure file operations
temp_file=$(create_temp_file ".tmp")
trap "secure_delete '$temp_file'" EXIT

# Check for dangerous patterns
[[ "$input" == *$'\0'* ]] && die $EXIT_SECURITY_VIOLATION "Null bytes detected"
```

## 📝 Adding New Scripts

### Template Structure
```bash
#!/bin/bash
#
# New RAMSAFE Tool
#
# Description of functionality
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Tool purpose
# USAGE: ./new_tool.sh <args>
#

# Load utility library
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Validate arguments
if [ "$#" -ne 1 ]; then
    echo "❌ ERROR: Invalid arguments"
    echo "📋 Usage: $0 <argument>"
    exit $EXIT_INVALID_ARGS
fi

# Check dependencies
check_dependencies "required_tool1" "required_tool2"

# Validate inputs
validated_input=$(validate_file_path "$1")

# Main logic
log_info "Processing: $validated_input"

# Output results
echo "Results..."

# Success
exit $EXIT_SUCCESS
```

### Testing Requirements
New scripts must include:
1. Unit tests for all validation functions
2. Integration tests for complete workflows
3. Error condition testing
4. Security validation testing

### Documentation Requirements
1. Update this development documentation
2. Add usage examples to user guide
3. Include troubleshooting information
4. Update help messages with examples

## 🚀 Contributing

### Development Workflow
1. Create feature branch
2. Implement changes following style guidelines
3. Add comprehensive tests
4. Update documentation
5. Run full test suite
6. Submit for review

### Quality Checklist
- [ ] Code follows style guidelines
- [ ] All inputs are validated
- [ ] Proper error handling with correct exit codes
- [ ] Comprehensive test coverage
- [ ] Documentation updated
- [ ] Security review completed
- [ ] No hardcoded credentials or paths

## 📚 References

- [RAMSAFE User Guide](user_guide.md)
- [Build Guide](build_guide.md)  
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Bats Testing Framework](https://github.com/bats-core/bats-core)
- [Bash Security Best Practices](https://mywiki.wooledge.org/BashGuide)

---

*This documentation is maintained as part of the RAMSAFE project. Keep it updated when making architectural changes.*