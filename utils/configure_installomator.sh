#!/bin/bash

# =============================================================================
# Installomator Configuration Script for macOS
# =============================================================================
# This script configures Installomator with custom labels from a GitHub repo
# Designed for use with Baseline from Second Son Consulting and Mosyle MDM
# 
# Author: Generated for macOS deployment automation
# Version: 1.0
# =============================================================================

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================

# GitHub repositories
CUSTOM_LABELS_REPO="https://github.com/avfx-it/avfx-mdm.git"
INSTALLOMATOR_REPO="https://github.com/Installomator/Installomator.git"

# Local paths
INSTALLOMATOR_PATH="/usr/local/Installomator"
INSTALLOMATOR_SCRIPT="$INSTALLOMATOR_PATH/Installomator.sh"
WORK_DIR="/tmp/installomator_config_$$"
BACKUP_DIR="/usr/local/Installomator/backup"

# Logging
LOG_FILE="/var/log/installomator_config.log"
SCRIPT_NAME="$(basename "$0")"

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $SCRIPT_NAME: $message" | tee -a "$LOG_FILE"
}

log_info() {
    log_message "INFO" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

cleanup() {
    log_info "Cleaning up temporary files..."
    if [[ -d "$WORK_DIR" ]]; then
        rm -rf "$WORK_DIR"
        log_info "Removed temporary directory: $WORK_DIR"
    fi
}

# Set up trap for cleanup on exit
trap cleanup EXIT

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        return 1
    fi
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed or not in PATH"
        return 1
    fi
    
    # Check if Installomator directory exists
    if [[ ! -d "$INSTALLOMATOR_PATH" ]]; then
        log_error "Installomator directory not found at $INSTALLOMATOR_PATH"
        return 1
    fi
    
    # Check if original Installomator.sh exists
    if [[ ! -f "$INSTALLOMATOR_SCRIPT" ]]; then
        log_error "Original Installomator.sh not found at $INSTALLOMATOR_SCRIPT"
        return 1
    fi
    
    log_info "Prerequisites check passed"
    return 0
}

create_backup() {
    log_info "Creating backup of current Installomator.sh..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Create backup with timestamp
    local backup_file="$BACKUP_DIR/Installomator.sh.backup.$(date +%Y%m%d_%H%M%S)"
    
    if cp "$INSTALLOMATOR_SCRIPT" "$backup_file"; then
        log_info "Backup created: $backup_file"
        return 0
    else
        log_error "Failed to create backup"
        return 1
    fi
}

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

pull_installomator_repo() {
    log_info "Pulling latest Installomator repository..."
    
    local installomator_dir="$WORK_DIR/Installomator"
    
    # Clone the repository
    if git clone "$INSTALLOMATOR_REPO" "$installomator_dir"; then
        log_info "Successfully cloned Installomator repository"
        return 0
    else
        log_error "Failed to clone Installomator repository"
        return 1
    fi
}

fetch_custom_labels() {
    log_info "Fetching custom labels from GitHub repository..."
    
    local custom_labels_dir="$WORK_DIR/custom_labels"
    local installomator_dir="$WORK_DIR/Installomator"
    local labels_target_dir="$installomator_dir/fragments/labels"
    
    # Clone custom labels repository
    if git clone "$CUSTOM_LABELS_REPO" "$custom_labels_dir"; then
        log_info "Successfully cloned custom labels repository"
    else
        log_error "Failed to clone custom labels repository"
        return 1
    fi
    
    # Check if labels directory exists in custom repo, or if labels are in root
    local labels_source_dir=""
    if [[ -d "$custom_labels_dir/labels" ]]; then
        labels_source_dir="$custom_labels_dir/labels"
        log_info "Found labels in subdirectory: labels/"
    else
        # Labels are in the root directory - look for .sh files
        if find "$custom_labels_dir" -maxdepth 1 -name "*.sh" -type f | grep -q .; then
            labels_source_dir="$custom_labels_dir"
            log_info "Found labels in root directory"
        else
            log_error "No label files (.sh) found in repository"
            return 1
        fi
    fi
    
    # Copy custom labels to Installomator fragments/labels directory
    if cp "$labels_source_dir"/*.sh "$labels_target_dir/" 2>/dev/null; then
        log_info "Successfully copied custom labels to Installomator"
        
        # List the copied labels for verification
        log_info "Custom labels added:"
        find "$labels_target_dir" -name "*.sh" -newer "$custom_labels_dir" -exec basename {} .sh \; 2>/dev/null | while read label; do
            log_info "  - $label"
        done
        
        return 0
    else
        log_error "Failed to copy custom labels"
        return 1
    fi
}

assemble_installomator() {
    log_info "Running Installomator assembly process..."
    
    local installomator_dir="$WORK_DIR/Installomator"
    local assemble_script="$installomator_dir/utils/assemble.sh"
    local build_dir="$installomator_dir/build"
    
    # Check if assemble.sh exists
    if [[ ! -f "$assemble_script" ]]; then
        log_error "Assembly script not found at $assemble_script"
        return 1
    fi
    
    # Make assemble.sh executable
    chmod +x "$assemble_script"
    
    # Change to Installomator directory - this is crucial for assemble.sh to work
    local original_dir=$(pwd)
    cd "$installomator_dir" || {
        log_error "Failed to change to Installomator directory"
        return 1
    }
    
    log_info "Changed to Installomator directory: $installomator_dir"
    
    # Create build directory if it doesn't exist
    mkdir -p "$build_dir"
    
    # Run the assembly script - it will create build/Installomator.sh
    log_info "Running ./utils/assemble.sh to build Installomator with custom labels..."
    if ./utils/assemble.sh; then
        log_info "Successfully assembled Installomator with custom labels"
        
        # Check if the assembled script was created
        if [[ -f "$build_dir/Installomator.sh" ]]; then
            log_info "Assembled Installomator.sh found at $build_dir/Installomator.sh"
        else
            log_error "Assembled Installomator.sh not found in build directory"
            cd "$original_dir"
            return 1
        fi
        
        cd "$original_dir"
        return 0
    else
        log_error "Failed to assemble Installomator"
        cd "$original_dir"
        return 1
    fi
}

replace_installomator() {
    log_info "Replacing existing Installomator.sh with new version..."
    
    local new_installomator="$WORK_DIR/Installomator/build/Installomator.sh"
    
    # Check if new Installomator.sh was created by assembly
    if [[ ! -f "$new_installomator" ]]; then
        log_error "New assembled Installomator.sh not found at $new_installomator"
        return 1
    fi
    
    # Get original file permissions and ownership
    local original_perms=$(stat -f "%Mp%Lp" "$INSTALLOMATOR_SCRIPT" 2>/dev/null)
    local original_owner=$(stat -f "%Su:%Sg" "$INSTALLOMATOR_SCRIPT" 2>/dev/null)
    
    # Replace the file
    if cp "$new_installomator" "$INSTALLOMATOR_SCRIPT"; then
        log_info "Successfully replaced Installomator.sh"
    else
        log_error "Failed to replace Installomator.sh"
        return 1
    fi
    
    # Restore original permissions and ownership
    if [[ -n "$original_perms" ]]; then
        chmod "$original_perms" "$INSTALLOMATOR_SCRIPT"
        log_info "Restored file permissions: $original_perms"
    else
        # Default permissions if we couldn't get the original
        chmod 755 "$INSTALLOMATOR_SCRIPT"
        log_info "Set default permissions: 755"
    fi
    
    if [[ -n "$original_owner" ]]; then
        chown "$original_owner" "$INSTALLOMATOR_SCRIPT"
        log_info "Restored file ownership: $original_owner"
    else
        # Default ownership
        chown root:wheel "$INSTALLOMATOR_SCRIPT"
        log_info "Set default ownership: root:wheel"
    fi
    
    # Verify the new file
    if [[ -x "$INSTALLOMATOR_SCRIPT" ]]; then
        log_info "New Installomator.sh is executable and ready"
        return 0
    else
        log_error "New Installomator.sh is not executable"
        return 1
    fi
}

verify_installation() {
    log_info "Verifying Installomator installation..."
    
    # Check if the script exists and is executable
    if [[ -x "$INSTALLOMATOR_SCRIPT" ]]; then
        log_info "Installomator.sh is present and executable"
    else
        log_error "Installomator.sh verification failed"
        return 1
    fi
    
    # Try to run Installomator with version flag (if supported)
    if "$INSTALLOMATOR_SCRIPT" version &>/dev/null; then
        log_info "Installomator responds to version command"
    else
        log_warning "Installomator version command not supported or failed"
    fi
    
    # Check file size (should be substantial)
    local file_size=$(stat -f%z "$INSTALLOMATOR_SCRIPT" 2>/dev/null)
    if [[ "$file_size" -gt 10000 ]]; then
        log_info "Installomator.sh file size looks reasonable: $file_size bytes"
    else
        log_warning "Installomator.sh file size seems small: $file_size bytes"
    fi
    
    return 0
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log_info "Starting Installomator configuration process..."
    log_info "Script version: 1.0"
    log_info "Working directory: $WORK_DIR"
    
    # Create working directory
    mkdir -p "$WORK_DIR"
    
    # Check prerequisites
    if ! check_prerequisites; then
        log_error "Prerequisites check failed. Exiting."
        exit 1
    fi
    
    # Create backup
    if ! create_backup; then
        log_error "Backup creation failed. Exiting for safety."
        exit 1
    fi
    
    # Step 1: Pull latest Installomator repo
    if ! pull_installomator_repo; then
        log_error "Failed to pull Installomator repository. Exiting."
        exit 1
    fi
    
    # Step 2: Get custom labels and put them in fragments/labels folder
    if ! fetch_custom_labels; then
        log_error "Failed to fetch custom labels. Exiting."
        exit 1
    fi
    
    # Step 3: Run ./utils/assemble.sh to add custom labels to the script
    if ! assemble_installomator; then
        log_error "Failed to assemble Installomator. Exiting."
        exit 1
    fi
    
    # Step 4: Replace existing Installomator.sh with proper permissions
    if ! replace_installomator; then
        log_error "Failed to replace Installomator.sh. Exiting."
        exit 1
    fi
    
    # Verify the installation
    if ! verify_installation; then
        log_error "Installation verification failed. Check the logs."
        exit 1
    fi
    
    log_info "Installomator configuration completed successfully!"
    log_info "Custom labels have been integrated and Installomator.sh has been updated."
    log_info "Log file: $LOG_FILE"
    
    return 0
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

