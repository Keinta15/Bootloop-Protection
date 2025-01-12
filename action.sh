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

# File to track disabled modules by this script
DISABLED_TRACK_FILE="$SELF/disabled_modules.txt"

# Create the track file if it doesn't exist
if [ ! -f "$DISABLED_TRACK_FILE" ]; then
    touch "$DISABLED_TRACK_FILE"
fi

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

        # Check if module is already disabled by the script
        if [ -f "$i/disable" ]; then
            # Check if the module was disabled by this script (it must be in the tracking file)
            if grep -q "^$i$" "$DISABLED_TRACK_FILE"; then
                echo "Module $MODULE_NAME was disabled by this script. Queuing for enabling."
                enable_list="$i $enable_list"
            else
                echo "Module $MODULE_NAME was disabled by something else. Skipping enabling."
            fi
        elif [ ! -f "$i/disable" ]; then
            # Only disable modules that are not already disabled by the script
            echo "Module $MODULE_NAME is not disabled. Queuing for disabling."
            disable_list="$disable_list $i"  # Add to disable list
        fi
    fi
done

# Enable previously disabled modules by this script
if [ -n "$enable_list" ]; then
    echo "Enabling modules disabled by this script..."
    for module in $enable_list; do
        # Enable the module (remove the disable file)
        if [ -f "$module/disable" ]; then
            rm -f "$module/disable" || echo "Failed to enable module: $module"
            echo "Enabled module: $(basename "$module")"
            # Remove the module from the track file after enabling it
            sed -i "\|$module|d" "$DISABLED_TRACK_FILE"
        fi
    done
else
    echo "No modules to enable"
fi

# Disable modules queued for disabling
if [ -n "$disable_list" ]; then
    echo "Disabling queued modules..."
    for module in $disable_list; do
        touch "$module/disable" || echo "Failed to disable module: $module"
        echo "$module" >> "$DISABLED_TRACK_FILE"  # Append to the tracking file
        echo "Disabled module: $(basename "$module")"
    done
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