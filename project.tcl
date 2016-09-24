set ns [new Simulator]

if {$argc == 1} {
	set discipline $argv
} else {
	puts "Usage: ns $argv0 DropTail|RED"
	exit 1
}

set namt [open out.nam w]
$ns namtrace-all $namt
set allt [open trace.tr w]
$ns trace-all $allt
set cwndt [open cwnd.tr w]
set seqnt [open seqnt.tr w]
set pseqn1 -1
set pseqn2 -1

proc finish {} {
	global ns namt allt cwndt seqnt discipline
	$ns flush-trace
	close $namt
	close $allt
	close $cwndt
	close $seqnt
	exec awk -f throughput.awk -v s=4.0 trace.tr > thrut1.tr
	exec awk -f throughput.awk -v s=4.1 trace.tr > thrut2.tr
	exec awk -f throughput.awk -v s=4.2 trace.tr > thrut3.tr
	exec gnuplot -e out='$discipline/throughput.png' throughput.gnuplot
	exec gnuplot -e out='$discipline/cwnd.png' cwnd.gnuplot
	exec gnuplot -e out='$discipline/seqn.png' seqn.gnuplot
	exit 0
}

proc get_cwnd {tcp} {
	set cwnd [$tcp set cwnd_]
	set wnd [$tcp set window_]
	if {$cwnd < $wnd} {
		set ret $cwnd
	} else {
		set ret $wnd
	}
	return $ret
}

set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

$s1 color "Blue"
$s2 color "Green"
$s3 color "Orange"

$ns duplex-link $s1 $r1 5Mb 10ms DropTail
$ns duplex-link $s2 $r1 5Mb 10ms DropTail
$ns duplex-link $s3 $r1 5Mb 10ms DropTail
$ns duplex-link $r1 $r2 10Mb 50ms $discipline

$ns duplex-link-op $s1 $r1 orient right-down
$ns duplex-link-op $s2 $r1 orient right
$ns duplex-link-op $s3 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right
$ns duplex-link-op $r1 $r2 queuePos 0.5

set tcp1 [new Agent/TCP/RFC793edu]
$ns attach-agent $s1 $tcp1
$tcp1 set window_ 150
$tcp1 set add793slowstart_ false
#$tcp1 set add793fastrtx_ false
#$tcp1 set add793jacobsonrtt_ false
#$tcp1 set add793karnrtt_ false
#$tcp1 set add793expbackoff_ false
$tcp1 set add793exponinc_ false
$tcp1 set add793additiveinc_ true
$tcp1 set fid_ 1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP/FullTcp]
$ns attach-agent $s2 $tcp2
$tcp2 set window_ 150
$tcp2 set fid_ 2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

set tcp4 [new Agent/TCPSink]
$ns attach-agent $r2 $tcp4

set tcp5 [new Agent/TCP/FullTcp]
$ns attach-agent $r2 $tcp5
$tcp5 listen

set udp3 [new Agent/UDP]
$udp3 set fid_ 3
$ns attach-agent $s3 $udp3

set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 500
$cbr3 set interval_ 0.0008
$cbr3 attach-agent $udp3
set null6 [new Agent/Null]
$ns attach-agent $r2 $null6

$ns connect $tcp1 $tcp4
$ns connect $tcp2 $tcp5
$ns connect $udp3 $null6

$ns color 1 Blue
$ns color 2 Green
$ns color 3 Orange

proc record {} {
	global ns tcp1 tcp2 cwndt seqnt
	set now [$ns now]
	set cwnd1 [get_cwnd $tcp1]
	set cwnd2 [get_cwnd $tcp2]
	set seqn1 [expr [$tcp1 set ack_] * 1000]
	set seqn2 [$tcp2 set ack_]
	puts $cwndt "$now $cwnd1 $cwnd2"
	puts $seqnt "$now $seqn1 $seqn2"
	$ns at [expr $now + 0.05] "record"
}

$ns at 0.1 "record"
$ns at 0.5 "$ftp1 start"
$ns at 0.5 "$ftp2 start"
$ns at 5.0 "$cbr3 start"
$ns at 10.0 "$ftp1 stop"
$ns at 10.0 "$ftp2 stop"
$ns at 10.0 "$cbr3 stop"
$ns at 10.1 "finish"
$ns run