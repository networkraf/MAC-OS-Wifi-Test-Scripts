#!/bin/bash
LOGFILE="$HOME/WIFI-TS/tcp_crash_report.log"
TARGET="192.168.10.1" # Change to your router IP

# Ensure we have sudo early
echo "Elevating privileges for radio and kernel diagnostics..."
sudo -v

echo "--- Monitoring for TCP/Driver Desync ---" | tee -a "$LOGFILE"

get_retrans() {
    # We use sudo here to ensure kernel stats are fully readable
    val=$(sudo netstat -s -p tcp | grep "retransmitted" | awk '{print $1}' | head -n 1)
    # Default to 0 if empty to prevent syntax errors
    echo "${val:-0}" | tr -d '[:space:]'
}

PREV_RETRANS=$(get_retrans)

while true; do
    # Keep the sudo ticket alive
    sudo -n true 2>/dev/null || sudo -v

    # Check for the stall (ping timeout)
    if ! ping -c 1 -W 500 $TARGET > /dev/null 2>&1; then
        TIMESTAMP=$(date '+%H:%M:%S')
        CURR_RETRANS=$(get_retrans)
        
        # Guarded math to prevent 'error token' crashes
        DIFF=$(( ${CURR_RETRANS:-0} - ${PREV_RETRANS:-0} ))
        
        if [ "$DIFF" -gt 0 ]; then
            echo "[$TIMESTAMP] STALL DETECTED: Radio is up, but TCP is failing." | tee -a "$LOGFILE"
            echo "    -> Retransmit Delta: +$DIFF" | tee -a "$LOGFILE"
            
            # Log the hardware state to prove the link is still active
            echo "--- HARDWARE STATE ---" >> "$LOGFILE"
            sudo wdutil info | grep -E "RSSI|Channel|Tx Rate|Width" >> "$LOGFILE"
            echo "-----------------------" >> "$LOGFILE"
            
            afplay /System/Library/Sounds/Basso.aiff
        fi
        PREV_RETRANS=$CURR_RETRANS
    else
        PREV_RETRANS=$(get_retrans)
    fi
    sleep 0.5
done
