#!/system/bin/env sh
# action.sh - Magisk module to manage other modules

# Script entry point
start() {
    echo """
#####################
# Bootloop Protection
# by Keinta15
#####################
    """
    sleep 1
    echo "> Performing checks..."
}

# Start the script
start

MODPATH="$(dirname "$0")"

# Provide feedback about script execution
echo "Initializing module management process..."

# Module directory to exclude from disabling
SELF="/data/adb/modules/bl_protection"

# Initialize lists for enabling and disabling modules
enable_list=""
disable_list=""

# Find all modules and classify them
for i in "$MODPATH"/../*; do
    if [ -d "$i" ]; then
        # Skip self-module
        if [ "$(realpath "$i")" = "$(realpath "$SELF")" ]; then
            echo "Skipping self-module: $(basename "$i")"
            continue
        fi

        # Check module status and queue for enabling or disabling
        if [ -f "$i/disable" ]; then
            echo "Queuing module for enabling: $(basename "$i")"
            enable_list="$i/disable $enable_list"
        elif [ ! -f "$i/disable" ]; then
            echo "Queuing module for disabling: $(basename "$i")"
            disable_list="$i/disable $disable_list"
        fi
    fi
done

# Enable previously disabled modules
if [ -n "$enable_list" ]; then
    echo "Enabling queued modules..."
    rm -f $enable_list || echo "Failed to enable some modules"
else
    echo "No modules to enable"
fi

# Disable modules queued for disabling
if [ -n "$disable_list" ]; then
    echo "Disabling queued modules..."
    touch $disable_list || echo "Failed to disable some modules"
else
    echo "No modules to disable"
fi

echo "Module management process complete."

# Final notification
echo -e "\nDone!"

# 10 seconds sleep on APatch on KernelSU

if [ -z "$MMRL" ] && { [ "$KSU" = "true" ] || [ "$APATCH" = "true" ]; }; then
echo -e "\nClosing dialog in 10 seconds ..."
sleep 10
fi

# Explicitly exit
exit 0