#!/system/bin/env sh
MODPATH="$(dirname "$0")"

# Initialize list of modules to disable
list=""

# Find all modules and queue for disabling
for module in "$MODPATH"/../*; do
    if [ -d "$module" ] && [ ! -f "$module/disable" ]; then
        list="$module/disable $list"
    fi
done

# Disable all queued modules
if [ -n "$list" ]; then
    touch $list || echo "Failed to disable some modules"
else
    echo "No modules to disable"
fi