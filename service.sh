#!/data/adb/magisk/busybox sh
# Bootloop saver by HuskyDG, modified by ez-me and modified yet again by Keinta15
# I'm making these changes just for fun and not to improve the code

# Get the path of the module directory
MODPATH="${0%/*}"

# Source utility functions from util_functions.sh
. "$MODPATH/util_functions.sh"

# Log the start of the script
log "Script execution started."

# Gather Zygote PIDs at different intervals
ZYGOTE_PID1=$(gather_zygote_pid 5)  # Gather PID after 5 seconds
log "PID1: $ZYGOTE_PID1"

ZYGOTE_PID2=$(gather_zygote_pid 15)  # Gather PID after 15 seconds
log "PID2: $ZYGOTE_PID2"

ZYGOTE_PID3=$(gather_zygote_pid 15)  # Gather PID after another 15 seconds
log "PID3: $ZYGOTE_PID3"

# Log the start of the Bootloop check
log "Checking for Bootloop..."

# Check if the first Zygote PID was retrieved
if [ -z "$ZYGOTE_PID1" ]; then
    log "Zygote didn't start?"  # Log if Zygote did not start
    disable_modules  # Call function to disable modules
    log "Modules disabled due to Zygote not starting."  # Log the action taken
fi

# Check for PID mismatches to detect potential Bootloop
if [ "$ZYGOTE_PID1" != "$ZYGOTE_PID2" ] || [ "$ZYGOTE_PID2" != "$ZYGOTE_PID3" ]; then
    log "PID mismatch detected, checking again..."  # Log PID mismatch
    sleep 15  # Wait for 15 seconds before checking again
    ZYGOTE_PID4=$(getprop init.svc_debug_pid.zygote)  # Get the fourth PID
    log "PID4: $ZYGOTE_PID4"

    # Check if the last two PIDs match
    if [ "$ZYGOTE_PID3" != "$ZYGOTE_PID4" ]; then
        log "PID mismatch persists, disabling modules..."  # Log if there is still a mismatch
        disable_modules  # Call function to disable modules
        log "Modules disabled due to persistent PID mismatch."  # Log the action taken
    else
        log "PID match confirmed after recheck."  # Log if PIDs match
    fi
else
    log "No PID mismatch detected."  # Log if no mismatch is found
fi

# Check if status.txt exists and read its content
if [ -f "$MODPATH/status.txt" ]; then
    # Read the first 100 characters from status.txt
    STATUS="$(head -c100 "$MODPATH/status.txt")"
    log "Read status from status.txt: $STATUS"  # Log the status read
else
    # If status.txt does not exist, set STATUS to a default message
    STATUS="ID: $ZYGOTE_PID1"
    log "status.txt not found, therefore no bootloop. Identifying $STATUS"  # Log the default status with Zygote ID
fi

# Call the function to modify the description
modify_description

# If we reached this section, everything is functioning correctly
log "Script completed successfully. All checks passed!"  # Success message
log "---------------------"  # Add a line for readability in logs
exit 0  # Exit the script successfully