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

        # Trim any trailing whitespace or newline from the module name
        MODULE_NAME=$(echo "$MODULE_NAME" | tr -d '\n' | sed 's/[[:space:]]*$//')

        # Check if module is already disabled by the script
        if [ -f "$i/disable" ]; then
            # Check if the module was disabled by this script (it must be in the tracking file)
            if grep -q "^$MODULE_NAME$" "$DISABLED_TRACK_FILE"; then
                echo "Module $MODULE_NAME was disabled by this script. Queuing for enabling."
                enable_list="$i $enable_list"
            else
                echo "Module $MODULE_NAME was disabled by something else. Skipping enabling."
            fi
        elif [ ! -f "$i/disable" ]; then
            # Only disable modules that are not already disabled by the script
            if ! grep -q "^$MODULE_NAME$" "$DISABLED_TRACK_FILE"; then
                echo "Module $MODULE_NAME is not disabled. Queuing for disabling."
                disable_list="$i $disable_list"  # Add to disable list
            fi
        fi
    fi
done

# Enable previously disabled modules by this script
if [ -n "$enable_list" ]; then
    echo "Enabling modules disabled by this script..."
    for module_dir in $enable_list; do
        # Extract the module name from module.prop
        MODULE_NAME=$(grep '^name=' "$module_dir/module.prop" | cut -d '=' -f 2)
        MODULE_NAME=$(echo "$MODULE_NAME" | tr -d '\n' | sed 's/[[:space:]]*$//')  # Trim any extra whitespace
        if [ -f "$module_dir/disable" ]; then
            rm -f "$module_dir/disable" || echo "Failed to enable module: $MODULE_NAME"
            echo "Enabled module: $MODULE_NAME"
            # Remove the track file after enabling them, this is to prevent manually enabled modules from being disabled 
            rm -f "$DISABLED_TRACK_FILE"
        fi
    done
    echo "Deleted disabled_modules.txt file"
fi

# Disable modules queued for disabling
if [ -n "$disable_list" ]; then
    echo "Disabling queued modules..."
    for module_dir in $disable_list; do
        # Extract the module name from module.prop
        MODULE_NAME=$(grep '^name=' "$module_dir/module.prop" | cut -d '=' -f 2)
        MODULE_NAME=$(echo "$MODULE_NAME" | tr -d '\n' | sed 's/[[:space:]]*$//')  # Trim any extra whitespace
        touch "$module_dir/disable" || echo "Failed to disable module: $MODULE_NAME"
        echo "$MODULE_NAME" >> "$DISABLED_TRACK_FILE"  # Append to the tracking file
        echo "Disabled module: $MODULE_NAME"
    done
    echo "Added modules to disabled_modules.txt file"
fi

# Debugging Output
# echo "Enable List: $enable_list"
# echo "Disable List: $disable_list"

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