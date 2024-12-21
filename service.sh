#!/data/adb/magisk/busybox sh
# Bootloop saver by HuskyDG, modified by ez-me and modified yet again by Keinta15
# I'm making these changes just for fun and not to improve the code

# Get variables
MODPATH=${0%/*}
MESSAGE="$(cat "$MODPATH"/msg.txt | head -c100)"

log "Started"

# Modify description
cp "$MODPATH/module.prop" "$MODPATH/temp.prop"
sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[Working. $MESSAGE] /g" "$MODPATH/temp.prop"
mv "$MODPATH/temp.prop" "$MODPATH/module.prop"

# Gather PIDs
sleep 5
ZYGOTE_PID1=$(getprop init.svc_debug_pid.zygote)
log "PID1: $ZYGOTE_PID1"

sleep 15
ZYGOTE_PID2=$(getprop init.svc_debug_pid.zygote)
log "PID2: $ZYGOTE_PID2"

sleep 15
ZYGOTE_PID3=$(getprop init.svc_debug_pid.zygote)
log "PID3: $ZYGOTE_PID3"

# Check for BootLoop
log "Checking..."

if [ -z "$ZYGOTE_PID1" ]
then
   log "Zygote didn't start?"
   disable_modules
fi

if [ "$ZYGOTE_PID1" != "$ZYGOTE_PID2" -o "$ZYGOTE_PID2" != "$ZYGOTE_PID3" ]
then
   log "PID mismatch, checking again"
   sleep 15
   ZYGOTE_PID4=$(getprop init.svc_debug_pid.zygote)
   log "PID4: $ZYGOTE_PID4"

   if [ "$ZYGOTE_PID3" != "$ZYGOTE_PID4" ]
   then
      log "They don't match..."
      disable_modules
   fi
fi

# If  we reached this section we should be fine
log "looks good to me!"
log ""
exit
