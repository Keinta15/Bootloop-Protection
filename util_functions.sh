# Log function to write messages to logs.txt
log() {
    local TEXT="$@"
    echo "[`date -Is`]: $TEXT" >> "$MODPATH/logs.txt"
}

# Function to disable modules when bootloop is detected
disable_modules() {
    log "Disabling modules..."  # Log the start of the module disabling process
    
    local list=""  # Initialize an empty list to hold paths of modules to disable
    
    # Iterate through module directories in the parent directory of MODPATH
    for modules in "$MODPATH/../"*; do
        # Check if the item is a directory and does not already have a 'disable' file
        if [[ -d "$modules" && ! -f "$modules/disable" ]]; then
            list="$modules/disable $list"  # Add the path to the list
            log "Preparing to disable module: $modules"  # Log the module being prepared for disabling
        fi
    done
    
    # Check if any modules were found to disable
    if [[ -n "$list" ]]; then
        touch $list && log "Modules disabled: $list"  # Create 'disable' files for the modules and log the action
        log "Modules disabled successfully."  # Log success message
    else
        log "No modules found to disable."  # Log if no modules were found
        return 1  # Exit the function with a non-zero status to indicate failure
    fi

    # Clean up any previous disable marker in the MODPATH
    rm -rf "$MODPATH/disable"
    
    # Log the action with a timestamp to a status file
    echo "Disabled modules at $(date -Is)" >> "$MODPATH/status.txt"
    
    # Remove system booting flags from various locations
    rm -rf /cache/.system_booting /data/unencrypted/.system_booting /metadata/.system_booting /persist/.system_booting /mnt/vendor/persist/.system_booting
    
    log "Rebooting..."  # Log the reboot action
    reboot  # Reboot the system
    exit 0  # Explicitly exit with a success status
}
