#!/usr/bin/env bats
#
# Unit tests for RAMSAFE utility library
#
# This test suite validates the core utility functions used across all RAMSAFE scripts
# including input validation, error handling, logging, and security functions.
#
# USAGE: bats tests/test_ramsafe_utils.bats
#

# Setup test environment
setup() {
    # Load the utility library
    source "$BATS_TEST_DIRNAME/../bin/ramsafe_utils.sh"
    
    # Create temporary directory for test files
    TEST_DIR=$(mktemp -d)
    
    # Create test files
    echo "test content" > "$TEST_DIR/valid_file.txt"
    echo "larger test content for size testing" > "$TEST_DIR/large_file.txt"
    touch "$TEST_DIR/empty_file.txt"
    
    # Create test directory structure
    mkdir -p "$TEST_DIR/subdir"
    echo "nested content" > "$TEST_DIR/subdir/nested_file.txt"
}

# Cleanup test environment
teardown() {
    # Remove test directory
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# =============================================================================
# INPUT VALIDATION TESTS
# =============================================================================

@test "validate_file_path: accepts valid file path" {
    run validate_file_path "$TEST_DIR/valid_file.txt"
    [ "$status" -eq 0 ]
    [[ "$output" == *"valid_file.txt"* ]]
}

@test "validate_file_path: rejects empty path" {
    run validate_file_path ""
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"cannot be empty"* ]]
}

@test "validate_file_path: rejects non-existent file" {
    run validate_file_path "$TEST_DIR/nonexistent.txt"
    [ "$status" -eq $EXIT_FILE_NOT_FOUND ]
    [[ "$output" == *"not found"* ]]
}

@test "validate_file_path: rejects null bytes" {
    run validate_file_path $'test\0file.txt'
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"null bytes"* ]]
}

@test "validate_file_path: rejects overly long paths" {
    # Create a path longer than 4096 characters
    long_path=$(printf "%*s" 5000 "" | tr ' ' 'a')
    run validate_file_path "$long_path"
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"too long"* ]]
}

@test "validate_url: accepts valid HTTP URL" {
    run validate_url "http://example.com/test.jpg"
    [ "$status" -eq 0 ]
    [[ "$output" == "http://example.com/test.jpg" ]]
}

@test "validate_url: accepts valid HTTPS URL" {
    run validate_url "https://example.com/path/to/file.png"
    [ "$status" -eq 0 ]
    [[ "$output" == "https://example.com/path/to/file.png" ]]
}

@test "validate_url: rejects empty URL" {
    run validate_url ""
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"cannot be empty"* ]]
}

@test "validate_url: rejects non-HTTP(S) URL" {
    run validate_url "ftp://example.com/file.txt"
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"Must start with http"* ]]
}

@test "validate_url: rejects localhost URL" {
    run validate_url "http://localhost/file.txt"
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"localhost"* ]]
}

@test "validate_url: rejects private IP URL" {
    run validate_url "http://192.168.1.1/file.txt"
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"private"* ]]
}

@test "validate_url: rejects URL with null bytes" {
    run validate_url $'http://example.com/test\0file.jpg'
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"null bytes"* ]]
}

@test "validate_url: rejects overly long URL" {
    # Create URL longer than MAX_URL_LENGTH
    long_url="https://example.com/$(printf "%*s" 3000 "" | tr ' ' 'a')"
    run validate_url "$long_url"
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"too long"* ]]
}

@test "validate_hash: accepts valid MD5 hash" {
    run validate_hash "d41d8cd98f00b204e9800998ecf8427e" "md5"
    [ "$status" -eq 0 ]
    [[ "$output" == "d41d8cd98f00b204e9800998ecf8427e" ]]
}

@test "validate_hash: accepts valid SHA256 hash" {
    run validate_hash "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" "sha256"
    [ "$status" -eq 0 ]
    [[ "$output" == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]]
}

@test "validate_hash: auto-detects hash type by length" {
    run validate_hash "d41d8cd98f00b204e9800998ecf8427e" "auto"
    [ "$status" -eq 0 ]
}

@test "validate_hash: rejects invalid hash characters" {
    run validate_hash "invalid_hash_with_spaces_and_symbols!" "md5"
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"invalid characters"* ]]
}

@test "validate_hash: rejects wrong length for hash type" {
    # 32 character hash passed as SHA256 (should be 64)
    run validate_hash "d41d8cd98f00b204e9800998ecf8427e" "sha256"
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"length"* ]]
}

@test "validate_examiner_id: accepts valid examiner ID" {
    run validate_examiner_id "Detective.Smith@police.gov"
    [ "$status" -eq 0 ]
    [[ "$output" == "Detective.Smith@police.gov" ]]
}

@test "validate_examiner_id: rejects empty examiner ID" {
    run validate_examiner_id ""
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"cannot be empty"* ]]
}

@test "validate_examiner_id: rejects overly long examiner ID" {
    long_id=$(printf "%*s" 200 "" | tr ' ' 'a')
    run validate_examiner_id "$long_id"
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"too long"* ]]
}

@test "validate_examiner_id: rejects null bytes" {
    run validate_examiner_id $'detective\0smith'
    [ "$status" -eq $EXIT_SECURITY_VIOLATION ]
    [[ "$output" == *"null bytes"* ]]
}

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

@test "check_dependency: passes for existing command" {
    run check_dependency "ls"
    [ "$status" -eq 0 ]
}

@test "check_dependency: fails for non-existent command" {
    run check_dependency "nonexistent_command_12345"
    [ "$status" -eq $EXIT_DEPENDENCY_MISSING ]
    [[ "$output" == *"not found"* ]]
}

@test "check_dependencies: passes for multiple existing commands" {
    run check_dependencies "ls" "cat" "echo"
    [ "$status" -eq 0 ]
}

@test "check_dependencies: fails if any command missing" {
    run check_dependencies "ls" "nonexistent_command_12345" "cat"
    [ "$status" -eq $EXIT_DEPENDENCY_MISSING ]
}

# =============================================================================
# SECURE FILE OPERATIONS
# =============================================================================

@test "create_temp_file: creates temporary file with restrictive permissions" {
    run create_temp_file
    [ "$status" -eq 0 ]
    
    # Check if file exists and has correct permissions
    temp_file="$output"
    [ -f "$temp_file" ]
    
    # Check permissions (should be 600)
    perms=$(stat -c "%a" "$temp_file" 2>/dev/null || stat -f "%Lp" "$temp_file" 2>/dev/null)
    [ "$perms" = "600" ]
    
    # Cleanup
    rm -f "$temp_file"
}

@test "create_temp_file: creates file with custom suffix" {
    run create_temp_file ".test"
    [ "$status" -eq 0 ]
    
    temp_file="$output"
    [[ "$temp_file" == *".test" ]]
    
    # Cleanup
    rm -f "$temp_file"
}

@test "secure_delete: removes existing file" {
    test_file="$TEST_DIR/delete_test.txt"
    echo "test content" > "$test_file"
    
    run secure_delete "$test_file"
    [ "$status" -eq 0 ]
    [ ! -f "$test_file" ]
}

@test "secure_delete: handles non-existent file gracefully" {
    run secure_delete "$TEST_DIR/nonexistent.txt"
    [ "$status" -eq 0 ]
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

@test "die: exits with correct code and message" {
    run bash -c "source '$BATS_TEST_DIRNAME/../bin/ramsafe_utils.sh'; die $EXIT_INVALID_ARGS 'test error message'"
    [ "$status" -eq $EXIT_INVALID_ARGS ]
    [[ "$output" == *"test error message"* ]]
}

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

@test "log_error: outputs error message to stderr" {
    run bash -c "source '$BATS_TEST_DIRNAME/../bin/ramsafe_utils.sh'; log_error 'test error'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ERROR: test error"* ]]
}

@test "log_info: outputs info message when log level allows" {
    run bash -c "RAMSAFE_LOG_LEVEL=3; source '$BATS_TEST_DIRNAME/../bin/ramsafe_utils.sh'; log_info 'test info'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"INFO: test info"* ]]
}

@test "log_debug: suppressed when log level too low" {
    run bash -c "RAMSAFE_LOG_LEVEL=3; source '$BATS_TEST_DIRNAME/../bin/ramsafe_utils.sh'; log_debug 'test debug'"
    [ "$status" -eq 0 ]
    [[ "$output" != *"DEBUG: test debug"* ]]
}

@test "log_debug: shown when log level allows" {
    run bash -c "RAMSAFE_LOG_LEVEL=4; source '$BATS_TEST_DIRNAME/../bin/ramsafe_utils.sh'; log_debug 'test debug'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"DEBUG: test debug"* ]]
}