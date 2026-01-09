######### Use at your own risk, this is for Educational and Testing purposes only ############ 
* wifi-stress-test.sh = launches one window in 10 panes use iTerm2 for Mac 
* wifi-stress-test.sh = The script calls monitor_health.sh for all the commands to run 
* monitor_health.sh = includes all the commands that are ran in each window pane that is called by wifi-stress-test.sh 
* tcp_crash_logger.sh = Monitoring for TCP/Driver Desync / kernel issue - logs to a file tcp_crash_report.log 

You need to moify at least IP addresses and install iperf3 on your pc and run one extra host as a server/client for iperf3 to send/receive data
Happy testing
