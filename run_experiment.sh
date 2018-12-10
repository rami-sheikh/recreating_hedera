INPUT_DIR=inputs
OUTPUT_DIR=results
INPUT_FILES='stag_prob_0_2_3_data'
#stag_prob_1_2_3_data stag_prob_2_2_3_data stag_prob_0_5_3_data stag_prob_1_5_3_data stag_prob_2_5_3_data stride1_data stride2_data stride4_data stride8_data random0_data random1_data random2_data random0_bij_data random1_bij_data random2_bij_data random_2_flows_data random_3_flows_data random_4_flows_data hotspot_one_to_one_data'
DURATION=10
CPU=0.015

kill_pox() {
    echo -n "killing pox instances: "
    procs=`ps aux | grep pox | grep -v grep | awk '{print $2}'`
    for p in $procs; do
        echo -ne "$p "
        kill $p
    done
    echo ""
}

start_pox() {
    ~/pox/pox.py --no-cli $1 --topo=ft,4 --routing=ECMP &
    echo "waiting for pox to startup"
    sleep 5
}

experiment() {

	for f in $INPUT_FILES;
	do
	        input_file=$INPUT_DIR/$f
	        pref="nonblocking"
	        out_dir=$OUTPUT_DIR/$pref/$f
	        sudo python hedera.py -k 6 -i $input_file -d $out_dir -p $CPU -t $DURATION -n --iperf -q $queue -b $bandwidth 
	done
	
	for f in $INPUT_FILES;
	do
	        input_file=$INPUT_DIR/$f
	        pref="fattree-ecmp"
	        out_dir=$OUTPUT_DIR/$pref/$f
	        kill_pox
	        start_pox DCController
	        sudo python hedera.py -k 6 -i $input_file -d $out_dir -p $CPU -t $DURATION --ecmp --iperf -q $queue -b $bandwidth 
	done
	
	for f in $INPUT_FILES;
	do
	        input_file=$INPUT_DIR/$f
	        pref="fattree-hedera"
	        out_dir=$OUTPUT_DIR/$pref/$f
	        kill_pox
	        start_pox HController
	        sudo python hedera.py -k 6 -i $input_file -d $out_dir -p $CPU -t $DURATION --hedera --iperf -q $queue -b $bandwidth 
	done

	kill_pox
}

queue=100
bandwidth=4

for bandwidth in `cat bw.txt`; do
	OUTPUT_DIR="outs/results_6b$bandwidth"
	experiment
done

bandwidth=10
for queue in `seq 200 -50 50`; do
	OUTPUT_DIR="outs/results_6q$queue"
	experiment
done
