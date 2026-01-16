#!/bin/bash
#
# RAMSAFE Utility Library
#
# This library provides common functions for input validation, error handling,
# logging, and cleanup operations used across all RAMSAFE scripts.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Centralized utility functions for security and consistency
# USAGE: Source this file at the beginning of RAMSAFE scripts
#
# Example: source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"
#

# =============================================================================
# CONSTANTS AND CONFIGURATION
# =============================================================================

# Standardized exit codes
declare -xr EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_INVALID_ARGS=2
readonly EXIT_FILE_NOT_FOUND=3
readonly EXIT_PERMISSION_DENIED=4
readonly EXIT_NETWORK_ERROR=5
readonly EXIT_DEPENDENCY_MISSING=6
readonly EXIT_VALIDATION_FAILED=7
readonly EXIT_SECURITY_VIOLATION=8

# Maximum allowed file size for processing (1GB)
readonly MAX_FILE_SIZE=1073741824

# Maximum URL length to prevent DoS attacks
readonly MAX_URL_LENGTH=2048

# Logging configuration
readonly LOG_LEVEL_ERROR=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_INFO=3
readonly LOG_LEVEL_DEBUG=4

# Default log level (can be overridden by scripts)
RAMSAFE_LOG_LEVEL=${RAMSAFE_LOG_LEVEL:-$LOG_LEVEL_INFO}

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Log a message with timestamp and level
# Usage: log_message LEVEL MESSAGE
log_message() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "$LOG_LEVEL_ERROR")
            echo "[$timestamp] ERROR: $message" >&2
            ;;
        "$LOG_LEVEL_WARN")
            if [ "$RAMSAFE_LOG_LEVEL" -ge "$LOG_LEVEL_WARN" ]; then
                echo "[$timestamp] WARN: $message" >&2
            fi
            ;;
        "$LOG_LEVEL_INFO")
            if [ "$RAMSAFE_LOG_LEVEL" -ge "$LOG_LEVEL_INFO" ]; then
                echo "[$timestamp] INFO: $message"
            fi
            ;;
        "$LOG_LEVEL_DEBUG")
            if [ "$RAMSAFE_LOG_LEVEL" -ge "$LOG_LEVEL_DEBUG" ]; then
                echo "[$timestamp] DEBUG: $message"
            fi
            ;;
    esac
}

# Convenience logging functions
log_error() { log_message "$LOG_LEVEL_ERROR" "$1"; }
log_warn() { log_message "$LOG_LEVEL_WARN" "$1"; }
log_info() { log_message "$LOG_LEVEL_INFO" "$1"; }
log_debug() { log_message "$LOG_LEVEL_DEBUG" "$1"; }

# =============================================================================
# ERROR HANDLING FUNCTIONS
# =============================================================================

# Display error message and exit with specified code
# Usage: die EXIT_CODE MESSAGE
die() {
    local exit_code=$1
    local message=$2
    log_error "$message"
    exit "$exit_code"
}

# Check if a command exists
# Usage: check_dependency COMMAND
check_dependency() {
    local cmd=$1
    if ! command -v "$cmd" &> /dev/null; then
        die "$EXIT_DEPENDENCY_MISSING" "Required dependency not found: $cmd. Please install it to continue."
    fi
}

# Check multiple dependencies
# Usage: check_dependencies "cmd1" "cmd2" "cmd3"
check_dependencies() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        check_dependency "$dep"
    done
}

# =============================================================================
# INPUT VALIDATION FUNCTIONS
# =============================================================================

# Validate file path and check if file exists and is readable
# Usage: validate_file_path PATH
validate_file_path() {
    local file_path=$1
    
    # Check if path is provided
    if [ -z "$file_path" ]; then
        die "$EXIT_INVALID_ARGS" "File path cannot be empty"
    fi
    
    # Check path length (prevent buffer overflow attempts)
    if [ ${#file_path} -gt 4096 ]; then
        die "$EXIT_SECURITY_VIOLATION" "File path too long (maximum 4096 characters)"
    fi
    
    # Check for null bytes (security measure)
    if [ "${#file_path}" -ne "$(printf '%s' "$file_path" | wc -c)" ]; then
        die "$EXIT_SECURITY_VIOLATION" "File path contains null bytes"
    fi
    
    # Resolve path to prevent directory traversal attacks
    local resolved_path
    if ! resolved_path=$(realpath -m "$file_path" 2>/dev/null); then
        die "$EXIT_INVALID_ARGS" "Invalid file path: $file_path"
    fi
    
    # Check if file exists
    if [ ! -f "$resolved_path" ]; then
        die "$EXIT_FILE_NOT_FOUND" "File not found: $resolved_path"
    fi
    
    # Check if file is readable
    if [ ! -r "$resolved_path" ]; then
        die "$EXIT_PERMISSION_DENIED" "File not readable: $resolved_path"
    fi
    
    # Check file size
    local file_size
    if command -v stat &>/dev/null; then
        file_size=$(stat -c%s "$resolved_path" 2>/dev/null || stat -f%z "$resolved_path" 2>/dev/null)
    else
        # Fallback to ls -l
        file_size=$(ls -l "$resolved_path" 2>/dev/null | awk '{print $5}')
    fi
    
    if [ -z "$file_size" ] || ! [[ "$file_size" =~ ^[0-9]+$ ]]; then
        die "$EXIT_GENERAL_ERROR" "Could not determine file size"
    fi
    
    if [ "$file_size" -gt "$MAX_FILE_SIZE" ]; then
        die "$EXIT_VALIDATION_FAILED" "File too large: $file_size bytes (maximum $MAX_FILE_SIZE bytes)"
    fi
    
    log_debug "File validation passed: $resolved_path ($file_size bytes)"
    echo "$resolved_path"
}

# Validate URL format and basic security checks
# Usage: validate_url URL
validate_url() {
    local url=$1
    
    # Check if URL is provided
    if [ -z "$url" ]; then
        die "$EXIT_INVALID_ARGS" "URL cannot be empty"
    fi
    
    # Check URL length
    if [ ${#url} -gt "$MAX_URL_LENGTH" ]; then
        die "$EXIT_SECURITY_VIOLATION" "URL too long (maximum $MAX_URL_LENGTH characters)"
    fi
    
    # Check for null bytes
    if [ "${#url}" -ne "$(printf '%s' "$url" | wc -c)" ]; then
        die "$EXIT_SECURITY_VIOLATION" "URL contains null bytes"
    fi
    
    # Basic URL format validation
    if [[ ! "$url" =~ ^https?:// ]]; then
        die "$EXIT_INVALID_ARGS" "Invalid URL format. Must start with http:// or https://"
    fi
    
    # Check for suspicious characters that might indicate injection attempts
    if [[ "$url" =~ [^a-zA-Z0-9._~:/\?#@!\$\&\'\(\)\*\+,=%|-] ]]; then
        die "$EXIT_SECURITY_VIOLATION" "URL contains potentially dangerous characters"
    fi
    
    # Prevent localhost/private IP access (basic protection)
    if [[ "$url" =~ ^https?://(localhost|127\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.) ]]; then
        die "$EXIT_SECURITY_VIOLATION" "Access to localhost/private IPs is not allowed"
    fi
    
    log_debug "URL validation passed: $url"
    echo "$url"
}

# Validate hash format (supports MD5, SHA1, SHA256, SHA512)
# Usage: validate_hash HASH [TYPE]
validate_hash() {
    local hash=$1
    local type=${2:-"auto"}
    
    if [ -z "$hash" ]; then
        die "$EXIT_INVALID_ARGS" "Hash cannot be empty"
    fi
    
    # Remove any whitespace
    hash=$(echo "$hash" | tr -d '[:space:]')
    
    # Check for valid hex characters only
    if [[ ! "$hash" =~ ^[a-fA-F0-9]+$ ]]; then
        die "$EXIT_INVALID_ARGS" "Hash contains invalid characters (must be hexadecimal)"
    fi
    
    # Validate hash length based on type
    case "$type" in
        "md5"|"MD5")
            if [ ${#hash} -ne 32 ]; then
                die "$EXIT_INVALID_ARGS" "Invalid MD5 hash length (expected 32 characters, got ${#hash})"
            fi
            ;;
        "sha1"|"SHA1")
            if [ ${#hash} -ne 40 ]; then
                die "$EXIT_INVALID_ARGS" "Invalid SHA1 hash length (expected 40 characters, got ${#hash})"
            fi
            ;;
        "sha256"|"SHA256")
            if [ ${#hash} -ne 64 ]; then
                die "$EXIT_INVALID_ARGS" "Invalid SHA256 hash length (expected 64 characters, got ${#hash})"
            fi
            ;;
        "sha512"|"SHA512")
            if [ ${#hash} -ne 128 ]; then
                die "$EXIT_INVALID_ARGS" "Invalid SHA512 hash length (expected 128 characters, got ${#hash})"
            fi
            ;;
        "auto")
            case ${#hash} in
                32) type="MD5" ;;
                40) type="SHA1" ;;
                64) type="SHA256" ;;
                128) type="SHA512" ;;
                *) die "$EXIT_INVALID_ARGS" "Unknown hash length: ${#hash} characters" ;;
            esac
            ;;
        *)
            die "$EXIT_INVALID_ARGS" "Unknown hash type: $type"
            ;;
    esac
    
    log_debug "Hash validation passed: $type hash with ${#hash} characters"
    echo "$hash"
}

# Validate examiner identifier (for chain of custody)
# Usage: validate_examiner_id EXAMINER_ID
validate_examiner_id() {
    local examiner_id=$1
    
    if [ -z "$examiner_id" ]; then
        die "$EXIT_INVALID_ARGS" "Examiner identifier cannot be empty"
    fi
    
    # Check length (reasonable bounds)
    if [ ${#examiner_id} -gt 100 ]; then
        die "$EXIT_INVALID_ARGS" "Examiner identifier too long (maximum 100 characters)"
    fi
    
    # Check for null bytes
    if [ "${#examiner_id}" -ne "$(printf '%s' "$examiner_id" | wc -c)" ]; then
        die "$EXIT_SECURITY_VIOLATION" "Examiner identifier contains null bytes"
    fi
    
    # Basic format validation (letters, numbers, spaces, common punctuation)
    if [[ ! "$examiner_id" =~ ^[a-zA-Z0-9._@\-\ ]+$ ]]; then
        die "$EXIT_INVALID_ARGS" "Examiner identifier contains invalid characters"
    fi
    
    log_debug "Examiner ID validation passed: $examiner_id"
    echo "$examiner_id"
}

# =============================================================================
# SECURE FILE OPERATIONS
# =============================================================================

# Create secure temporary file
# Usage: create_temp_file [SUFFIX]
create_temp_file() {
    local suffix=${1:-""}
    local temp_file
    
    if ! temp_file=$(mktemp ${suffix:+--suffix="$suffix"}); then
        die "$EXIT_GENERAL_ERROR" "Failed to create temporary file"
    fi
    
    # Set restrictive permissions
    chmod 600 "$temp_file"
    
    log_debug "Created temporary file: $temp_file"
    echo "$temp_file"
}

# Securely delete file
# Usage: secure_delete FILE_PATH
secure_delete() {
    local file_path=$1
    
    if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
        log_warn "Cannot securely delete: file does not exist or path is empty"
        return 0
    fi
    
    log_debug "Securely deleting: $file_path"
    
    # Try shred first (more secure)
    if command -v shred &> /dev/null; then
        shred -f -z -u "$file_path" 2>/dev/null && return 0
    fi
    
    # Fallback to rm
    rm -f "$file_path"
}

# =============================================================================
# NETWORK OPERATIONS
# =============================================================================

# Download file with security checks
# Usage: secure_download URL OUTPUT_FILE
secure_download() {
    local url=$1
    local output_file=$2
    
    # Validate inputs
    url=$(validate_url "$url")
    
    if [ -z "$output_file" ]; then
        die "$EXIT_INVALID_ARGS" "Output file path cannot be empty"
    fi
    
    log_info "Downloading from: $url"
    
    # Check curl dependency
    check_dependency "curl"
    
    # Download with security options
    if ! curl -L -f -s -S \
        --max-time 300 \
        --max-filesize "$MAX_FILE_SIZE" \
        --user-agent "RAMSAFE/1.0" \
        --proto "=http,https" \
        --proto-redir "=https" \
        -o "$output_file" \
        "$url"; then
        die "$EXIT_NETWORK_ERROR" "Failed to download file from: $url"
    fi
    
    # Verify download
    if [ ! -f "$output_file" ] || [ ! -s "$output_file" ]; then
        die "$EXIT_NETWORK_ERROR" "Download failed or resulted in empty file"
    fi
    
    local file_size
    file_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)
    log_info "Successfully downloaded $file_size bytes"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize the utility library
# Usage: Called automatically when sourced
_ramsafe_utils_init() {
    # Set secure defaults
    set -euo pipefail
    
    # Set secure PATH
    export PATH="/usr/local/bin:/usr/bin:/bin"
    
    # Clear environment variables that could be dangerous
    unset IFS
    
    log_debug "RAMSAFE utility library initialized"
}

# Auto-initialize when sourced
_ramsafe_utils_init