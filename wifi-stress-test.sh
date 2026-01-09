#!/bin/bash
SCRIPT_DIR="$HOME/WIFI-TS"
LOGFILE="$SCRIPT_DIR/wifi-stress-test.log"

# Cleanup function: Kills monitors and iperf when you exit
cleanup() {
    echo -e "\n--- Stopping Stress Test and Cleaning Up ---"
    # Added sudo here to permit killing root-owned monitor processes
    sudo pkill -f "monitor_health.sh"
    sudo pkill -f "iperf3"
    exit
}
trap cleanup SIGINT SIGTERM

# Clear log
echo "--- SESSION START $(date) ---" > "$LOGFILE"

# Pre-auth once
echo "Authorize WiFi diagnostics:"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Tunings
sudo ifconfig awdl0 down
sudo sysctl -w net.inet.tcp.delayed_ack=0
sudo sysctl -w kern.ipc.maxsockbuf=8388608

osascript <<EOF
tell application "iTerm"
    activate
    set newWin to (create window with default profile)
    tell current session of newWin
        set p1 to it
        set p6 to (split vertically with default profile)
        set p2 to (split horizontally with default profile)
        set p3 to (split horizontally with default profile)
        set p4 to (split horizontally with default profile)
        set p5 to (split horizontally with default profile)
        select p6
        set p7 to (split horizontally with default profile)
        set p8 to (split horizontally with default profile)
        set p9 to (split horizontally with default profile)
        set p10 to (split horizontally with default profile)
    end tell

    delay 1.0
    
    tell p1 to write text "sudo $SCRIPT_DIR/monitor_health.sh ping"
    tell p2 to write text "iperf3 -c 192.168.10.174 -p 7777 -t 3600"
    tell p3 to write text "sudo $SCRIPT_DIR/monitor_health.sh autofix"
    tell p4 to write text "sudo $SCRIPT_DIR/monitor_health.sh bandwidth"
    tell p5 to write text "sudo $SCRIPT_DIR/monitor_health.sh thermal"
    tell p6 to write text "sudo $SCRIPT_DIR/monitor_health.sh radio"
    tell p7 to write text "sudo $SCRIPT_DIR/monitor_health.sh mbuf_stats"
    tell p8 to write text "sudo $SCRIPT_DIR/monitor_health.sh tcp"
    tell p9 to write text "sudo $SCRIPT_DIR/monitor_health.sh zombies"
    tell p10 to write text "sudo $SCRIPT_DIR/monitor_health.sh logs"
end tell
EOF

echo "Test running. Press Control+C here to stop all."
wait