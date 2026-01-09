#!/bin/bash
MODE=$1
INTERFACE="en0"
LOGFILE="$HOME/WIFI-TS/wifi-stress-test.log"
DIAG_DEST="$HOME/Desktop/Apple_Support_Logs"

write_log() {
    echo "$(date '+%H:%M:%S') [$1] $2" >> "$LOGFILE"
}

trigger_apple_diagnostics() {
    write_log "ALERT" "Stall detected. Running sysdiagnose..."
    mkdir -p "$DIAG_DEST"
    sudo -n /usr/bin/sysdiagnose -u -f "$DIAG_DEST" &
}

case $MODE in
    "ping")
        echo "Starting Ping Monitor (Real-time)..."
        ping 192.168.10.1 | while read -r line; do
            echo "$line"
            write_log "PING" "$line"
            [[ "$line" == *"Request timeout"* ]] && trigger_apple_diagnostics
        done ;;

    "thermal")
        while true; do
            # This looks for a line with a number. If none found, defaults to 100.
            L=$(pmset -g therm | grep -oE '[0-9]+' | head -n 1)
            if [ -z "$L" ]; then L="100"; fi
            echo "THERM Level: ${L}%" | tee -a "$LOGFILE"
            sleep 5
        done ;;

    "tcp")
        while true; do
            # Narrowed down to only 'data packets retransmitted' to stop double lines
            RTX=$(netstat -s -p tcp | grep "data packets retransmitted" | awk '{print $1}' | tr -d '[:space:]')
            echo "TCP Retransmits: ${RTX:-0}" | tee -a "$LOGFILE"
            sleep 2
        done ;;

    "autofix")
        while true; do
            D=$(netstat -m | grep -i "denied" | grep -oE '[0-9]+' | head -n 1)
            echo "FIXER Deny-Count: ${D:-0}" | tee -a "$LOGFILE"
            sleep 3
        done ;;

    "radio")
        while true; do
            R=$(sudo -n wdutil info 2>/dev/null | grep -E "RSSI|MCS|Tx Rate|NSS" | xargs echo)
            echo "RADIO: ${R:-No Signal}" | tee -a "$LOGFILE"
            sleep 3
        done ;;

    "mbuf_stats")
        while true; do
            M=$(netstat -m | grep -E "mbufs? in use" | awk '{print $1}')
            echo "MBUF In-Use: ${M:-N/A}" | tee -a "$LOGFILE"
            sleep 5
        done ;;

    "bandwidth")
        netstat -I $INTERFACE -w 1 ;;

    "logs")
        sudo -n log stream --predicate 'process == "kernel" && eventMessage contains "WiFi"' --level error ;;

    "zombies")
        while true; do
            Z=$(netstat -an | grep -cE 'WAIT|CLOSE' | wc -l)
            echo "ZOMBIES: $Z" | tee -a "$LOGFILE"
            sleep 2
        done ;;
esac