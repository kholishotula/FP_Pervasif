# Define options
set val(chan)	Channel/WirelessChannel;	# channel type
set val(prop)	Propagation/TwoRayGround;	# radio-propagation model
set val(netif)	Phy/WirelessPhy ;		# network interface type
set val(mac)	Mac/802_11 ;			# MAC type
set val(ifq)	Queue/DropTail/PriQueue ;	# interface queue type
set val(ll)	LL ;				# link layer type
set val(ant)	Antenna/OmniAntenna ;		# antenna model
set val(ifqlen)	50 ;				# max packet in ifq
set val(nn)	17 ;				# number of mobilenodes
set val(rp)	AODV ;				# routing protocol
set val(x)	1000 ;				# X dimension of topography
set val(y)	600 ;				# Y dimension of topography
set val(stop)	150.0 ;				# time of simulation end

set ns [new Simulator]

set tracefd [open aodv.tr w]
$ns trace-all $tracefd
$ns use-newtrace

set namtrace [open aodv.nam w]
$ns namtrace-all $namtrace
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# general operation director creation
create-god $val(nn)

# create wireless channel
set chan [new $val(chan)];

# configure the nodes
$ns node-config -adhocRouting	$val(rp) \
		-llType		$val(ll) \
		-macType	$val(mac) \
		-ifqType	$val(ifq) \
		-ifqLen		$val(ifqlen) \
		-antType	$val(ant) \
		-propType	$val(prop) \
		-phyType	$val(netif) \
		-channel	$chan \
		-energyModel	"EnergyModel" \
		-initialEnergy	100.0 \
		-txPower	0.9 \
		-rxPower	0.5 \
		-idlePower	0.45 \
		-sleepPower	0.05 \
		-topoInstance	$topo \
		-agentTrace	ON \
		-routerTrace	ON \
		-macTrace	ON \
		-movementTrace	ON \

for {set i 0} {$i <$val(nn) } { incr i } {
	set node($i) [$ns node]
}

# Provide initial location of mobilenodes
$node(0) set X_ 199
$node(0) set Y_ 443
$node(0) set Z_ 0.0

$node(1) set X_ 361
$node(1) set Y_ 432
$node(1) set Z_ 0.0

$node(2) set X_ 363
$node(2) set Y_ 287
$node(2) set Z_ 0.0

$node(3) set X_ 210
$node(3) set Y_ 271
$node(3) set Z_ 0.0

$node(4) set X_ 246
$node(4) set Y_ 139
$node(4) set Z_ 0.0

$node(5) set X_ 402
$node(5) set Y_ 141
$node(5) set Z_ 0.0

$node(6) set X_ 499
$node(6) set Y_ 261
$node(6) set Z_ 0.0

$node(7) set X_ 564
$node(7) set Y_ 418
$node(7) set Z_ 0.0

$node(8) set X_ 609
$node(8) set Y_ 292
$node(8) set Z_ 0.0

$node(9) set X_ 312
$node(9) set Y_ 115
$node(9) set Z_ 0.0

$node(10) set X_ 370
$node(10) set Y_ 41
$node(10) set Z_ 0.0

$node(11) set X_ 688
$node(11) set Y_ 156
$node(11) set Z_ 0.0

$node(12) set X_ 758
$node(12) set Y_ 316
$node(12) set Z_ 0.0

$node(13) set X_ 728
$node(13) set Y_ 428
$node(13) set Z_ 0.0

$node(14) set X_ 695
$node(14) set Y_ 54
$node(14) set Z_ 0.0

$node(15) set X_ 556
$node(15) set Y_ 21
$node(15) set Z_ 0.0

$node(16) set X_ 856
$node(16) set Y_ 188
$node(16) set Z_ 0.0

# Define node initial position in nam
for {set i 0} {$i <$val(nn)} { incr i } {
	# 20 defines the node size for nam
	$ns initial_node_pos $node($i) 20
}

# Generation of movements
# at what time, which node, where to, at what speed
$ns at 10.0 "$node(2) setdest 500 300 5"
$ns at 25.0 "$node(2) setdest 600 500 15"
$ns at 12.0 "$node(9) setdest 363 287 15"
$ns at 30.0 "$node(0) setdest 700 54 12"

# Set a TCP connection between node (3) and node (12)
set tcp [new Agent/TCP/Newreno]
set sink [new Agent/TCPSink]
$ns attach-agent $node(3) $tcp
$ns attach-agent $node(12) $sink
$ns connect $tcp $sink
$tcp set packetSize_ 1500
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"


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
	exit 0
}

$ns run
