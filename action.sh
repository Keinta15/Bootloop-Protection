#!/system/bin/env sh

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

# Get the name of the self-module from module.prop
if [ -f "$SELF/module.prop" ]; then
    SELF_MODULE_NAME=$(grep '^name=' "$SELF/module.prop" | cut -d '=' -f 2)
else
    SELF_MODULE_NAME="bl_protection"  # Fallback to the directory name if module.prop doesn't exist
fi

# Initialize lists for enabling and disabling modules
enable_list=""
disable_list=""

# Find all modules and classify them
for i in "$MODPATH"/../*; do
    if [ -d "$i" ]; then
        # Skip self-module
        if [ "$(realpath "$i")" = "$(realpath "$SELF")" ]; then
            echo "Skipping self-module: $SELF_MODULE_NAME"
            continue
        fi

        # Get the module name from module.prop
        if [ -f "$i/module.prop" ]; then
            MODULE_NAME=$(grep '^name=' "$i/module.prop" | cut -d '=' -f 2)
        else
            MODULE_NAME=$(basename "$i")  # Fallback to directory name
        fi

        # Check module status and queue for enabling or disabling
        if [ -f "$i/disable" ]; then
            echo "Queuing module for enabling: $MODULE_NAME"
            enable_list="$i/disable $enable_list"
        elif [ ! -f "$i/disable" ]; then
            echo "Queuing module for disabling: $MODULE_NAME"
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