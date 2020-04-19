# wireless-aodv.tcl
# A 3 nodes example for ad hoc simulation with AODV

# Define options
set val(chan) Channel/WirelessChannel;# channel type
set val(prop) Propagation/TwoRayGround;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 3 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 500 ;# X dimension of topography
set val(y) 400 ;# Y dimension of topography
set val(stop) 150 ;# time of simulation end
set ns [new Simulator]
set tracefd [open simple.tr w]
set namtrace [open simwrls.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

# Create nn mobilenodes [$val(nn)] and attach them to the channel.
set chan_1_ [new $val(chan)]

# configure the nodes
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-channel $chan_1_ \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON \

for {set i 0} {$i <$val(nn) } { incr i } {
	set node($i) [$ns node]
}

# Provide initial location of mobilenodes
$node(0) set X_ 5.0
$node(0) set Y_ 5.0
$node(0) set Z_ 0.0
$node(1) set X_ 490.0
$node(1) set Y_ 285.0
$node(1) set Z_ 0.0
$node(2) set X_ 150.0
$node(2) set Y_ 240.0
$node(2) set Z_ 0.0

# Generation of movements
$ns at 10.0 "$node(0) setdest 250.0 250.0 3.0"
$ns at 15.0 "$node(1) setdest 45.0 285.0 5.0"
$ns at 110.0 "$node(0) setdest 480.0 300.0 5.0"

# Set a TCP connection between node (0) and node (1)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp
$ns attach-agent $node(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"

# Define node initial position in nam
for {set i 0} {$i <$val(nn)} { incr i } {
	# 30 defines the node size for nam
	$ns initial_node_pos $node($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i <$val(nn) } { incr i } {
	$ns at $val(stop) "$node($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace
	exec nam out.nam &
	exit 0
}

$ns run
