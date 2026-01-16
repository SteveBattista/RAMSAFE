#!/usr/bin/env bats
#
# Integration tests for RAMSAFE shell scripts
#
# This test suite validates the complete functionality of RAMSAFE scripts
# including error handling, input validation, and output format.
#
# USAGE: bats tests/test_scripts.bats
#

# Setup test environment
setup() {
    # Create temporary directory for test files
    TEST_DIR=$(mktemp -d)
    
    # Create test files
    echo "test image content" > "$TEST_DIR/test_image.jpg"
    echo "another test file" > "$TEST_DIR/test_file.txt"
    
    # Create an image-like file with proper size for testing
    dd if=/dev/zero of="$TEST_DIR/valid_image.jpg" bs=1024 count=10 2>/dev/null
    
    # Set up PATH to include our bin directory
    export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
    
    # Create a mock HTTP server response for testing
    MOCK_URL="https://httpbin.org/status/200"
}

# Cleanup test environment
teardown() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# =============================================================================
# SUMMARY_FILE.SH TESTS
# =============================================================================

@test "summary_file.sh: shows usage when no arguments provided" {
    run summary_file.sh
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"ERROR: Incorrect number of arguments"* ]]
}

@test "summary_file.sh: shows usage with help examples" {
    run summary_file.sh
    [ "$status" -eq 2 ]
    [[ "$output" == *"Examples:"* ]]
    [[ "$output" == *"/path/to/evidence.jpg"* ]]
}

@test "summary_file.sh: rejects non-existent file" {
    run summary_file.sh "$TEST_DIR/nonexistent.jpg"
    [ "$status" -eq 3 ]  # EXIT_FILE_NOT_FOUND
    [[ "$output" == *"not found"* ]]
}

@test "summary_file.sh: rejects empty file path" {
    run summary_file.sh ""
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"cannot be empty"* ]]
}

@test "summary_file.sh: validates file path with directory traversal attempt" {
    run summary_file.sh "../../../etc/passwd"
    [ "$status" -eq 3 ]  # Should fail - file likely doesn't exist in test env
}

@test "summary_file.sh: handles file with null bytes in path" {
    run bash -c "summary_file.sh \$'$TEST_DIR/test\\0file.jpg'"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"null bytes"* ]]
}

# =============================================================================
# SUMMARY_URL.SH TESTS
# =============================================================================

@test "summary_url.sh: shows usage when no arguments provided" {
    run summary_url.sh
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"ERROR: Incorrect number of arguments"* ]]
}

@test "summary_url.sh: rejects invalid URL format" {
    run summary_url.sh "invalid-url"
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Invalid URL format"* ]]
}

@test "summary_url.sh: rejects FTP URL" {
    run summary_url.sh "ftp://example.com/file.jpg"
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Must start with http"* ]]
}

@test "summary_url.sh: rejects localhost URL" {
    run summary_url.sh "http://localhost/file.jpg"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"localhost"* ]]
}

@test "summary_url.sh: rejects private IP URL" {
    run summary_url.sh "http://192.168.1.1/file.jpg"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"private"* ]]
}

@test "summary_url.sh: rejects URL with suspicious characters" {
    run summary_url.sh "http://example.com/file.jpg\$(whoami)"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"dangerous characters"* ]]
}

@test "summary_url.sh: accepts valid HTTPS URL format" {
    # This test only validates URL format, doesn't actually download
    run bash -c "timeout 5 summary_url.sh https://httpbin.org/status/200 <<< \$'Detective Smith\\nTest notes' || true"
    # We expect this to fail on network/timeout, but not on URL validation
    [[ "$output" != *"Invalid URL format"* ]]
    [[ "$output" != *"dangerous characters"* ]]
}

# =============================================================================
# VERIFY_ISO.SH TESTS
# =============================================================================

@test "verify_iso.sh: shows usage when no arguments provided" {
    run verify_iso.sh
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"ERROR: No ISO file path provided"* ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "verify_iso.sh: shows help message" {
    run verify_iso.sh --help
    [ "$status" -eq 0 ]  # EXIT_SUCCESS
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Examples:"* ]]
}

@test "verify_iso.sh: rejects invalid option" {
    run verify_iso.sh --invalid-option test.iso
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Unknown option"* ]]
}

@test "verify_iso.sh: rejects non-existent file" {
    run verify_iso.sh "$TEST_DIR/nonexistent.iso"
    [ "$status" -eq 3 ]  # EXIT_FILE_NOT_FOUND
    [[ "$output" == *"not found"* ]]
}

@test "verify_iso.sh: validates hash format" {
    # Create a dummy file to test with
    echo "test" > "$TEST_DIR/test.iso"
    run verify_iso.sh --hash "invalid_hash" "$TEST_DIR/test.iso"
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"invalid characters"* ]] || [[ "$output" == *"length"* ]]
}

@test "verify_iso.sh: accepts custom hash parameter" {
    echo "test content" > "$TEST_DIR/test.iso"
    # Calculate actual hash for this test content
    expected_hash=$(sha256sum "$TEST_DIR/test.iso" | cut -d' ' -f1)
    
    run verify_iso.sh --hash "$expected_hash" "$TEST_DIR/test.iso"
    [ "$status" -eq 0 ]  # EXIT_SUCCESS
    [[ "$output" == *"VERIFICATION PASSED"* ]]
}

# =============================================================================
# SSDEEP_COMPARE_FILES.SH TESTS
# =============================================================================

@test "ssdeep_compare_files.sh: shows usage when incorrect arguments provided" {
    run ssdeep_compare_files.sh
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"ERROR: Incorrect number of arguments"* ]]
}

@test "ssdeep_compare_files.sh: shows usage with one argument" {
    run ssdeep_compare_files.sh "$TEST_DIR/test_image.jpg"
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Usage:"* ]]
}

@test "ssdeep_compare_files.sh: rejects non-existent first file" {
    run ssdeep_compare_files.sh "$TEST_DIR/nonexistent1.jpg" "$TEST_DIR/test_image.jpg"
    [ "$status" -eq 3 ]  # EXIT_FILE_NOT_FOUND
    [[ "$output" == *"not found"* ]]
}

@test "ssdeep_compare_files.sh: rejects non-existent second file" {
    run ssdeep_compare_files.sh "$TEST_DIR/test_image.jpg" "$TEST_DIR/nonexistent2.jpg"
    [ "$status" -eq 3 ]  # EXIT_FILE_NOT_FOUND
    [[ "$output" == *"not found"* ]]
}

@test "ssdeep_compare_files.sh: requires ssdeep dependency" {
    # Temporarily make ssdeep unavailable
    run bash -c "PATH=/usr/bin:/bin ssdeep_compare_files.sh '$TEST_DIR/test_image.jpg' '$TEST_DIR/test_file.txt'"
    # Should exit with dependency missing error if ssdeep not in limited PATH
    [ "$status" -ne 0 ]
}

# =============================================================================
# SSDEEP_COMPARE_URLS.SH TESTS
# =============================================================================

@test "ssdeep_compare_urls.sh: shows usage when incorrect arguments provided" {
    run ssdeep_compare_urls.sh
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"ERROR: Incorrect number of arguments"* ]]
}

@test "ssdeep_compare_urls.sh: rejects invalid first URL" {
    run ssdeep_compare_urls.sh "invalid-url" "https://example.com/file2.jpg"
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Invalid URL format"* ]]
}

@test "ssdeep_compare_urls.sh: rejects invalid second URL" {
    run ssdeep_compare_urls.sh "https://example.com/file1.jpg" "ftp://example.com/file2.jpg"
    [ "$status" -eq 2 ]  # EXIT_INVALID_ARGS
    [[ "$output" == *"Must start with http"* ]]
}

@test "ssdeep_compare_urls.sh: validates both URLs before processing" {
    run ssdeep_compare_urls.sh "http://localhost/file1.jpg" "http://192.168.1.1/file2.jpg"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    # Should fail on first URL (localhost), so won't get to second URL validation
    [[ "$output" == *"localhost"* ]]
}

# =============================================================================
# DEPENDENCY TESTING
# =============================================================================

@test "All scripts check for required dependencies" {
    # Test that scripts properly check for their dependencies
    
    # summary_file.sh should check for jq, ssdeep, etc.
    run bash -c "PATH=/usr/bin:/bin summary_file.sh '$TEST_DIR/test_image.jpg'"
    # Should fail due to missing dependencies, not due to argument issues
    [ "$status" -ne 0 ]
    
    # summary_url.sh should check for jq, curl, ssdeep
    run bash -c "PATH=/usr/bin:/bin summary_url.sh https://example.com/test.jpg"
    [ "$status" -ne 0 ]
}

# =============================================================================
# SECURITY TESTS
# =============================================================================

@test "Scripts reject command injection attempts in file paths" {
    # Test various injection attempts
    run summary_file.sh "\$(whoami)"
    [ "$status" -ne 0 ]
    [[ "$output" != *"root"* ]]  # Should not execute whoami
    
    run summary_file.sh "; rm -rf /"
    [ "$status" -ne 0 ]
}

@test "Scripts reject command injection attempts in URLs" {
    run summary_url.sh "http://example.com/\$(whoami).jpg"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"dangerous characters"* ]]
}

@test "Scripts handle very long inputs safely" {
    # Test with extremely long file path
    long_path=$(printf "%*s" 5000 "a")
    run summary_file.sh "$long_path"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"too long"* ]]
    
    # Test with extremely long URL
    long_url="https://example.com/$(printf "%*s" 3000 "a").jpg"
    run summary_url.sh "$long_url"
    [ "$status" -eq 8 ]  # EXIT_SECURITY_VIOLATION
    [[ "$output" == *"too long"* ]]
}

# =============================================================================
# OUTPUT FORMAT TESTS
# =============================================================================

@test "Error messages are consistent across scripts" {
    # Test that all scripts use consistent error message formats
    
    run summary_file.sh
    [[ "$output" == *"❌ ERROR:"* ]]
    
    run summary_url.sh
    [[ "$output" == *"❌ ERROR:"* ]]
    
    run verify_iso.sh
    [[ "$output" == *"❌ ERROR:"* ]]
    
    run ssdeep_compare_files.sh
    [[ "$output" == *"❌ ERROR:"* ]]
    
    run ssdeep_compare_urls.sh
    [[ "$output" == *"❌ ERROR:"* ]]
}

@test "Usage messages include examples" {
    # Test that usage messages are helpful
    
    run summary_file.sh
    [[ "$output" == *"Examples:"* ]]
    [[ "$output" == *"Usage:"* ]]
    
    run summary_url.sh
    [[ "$output" == *"Examples:"* ]]
    [[ "$output" == *"Usage:"* ]]
    
    run ssdeep_compare_files.sh
    [[ "$output" == *"Examples:"* ]]
    [[ "$output" == *"Usage:"* ]]
}