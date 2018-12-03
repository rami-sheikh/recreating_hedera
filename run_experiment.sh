INPUT_DIR=inputs
OUTPUT_DIR=results
INPUT_FILES='stag_prob_0_2_3_data stag_prob_1_2_3_data stag_prob_2_2_3_data stag_prob_0_5_3_data stag_prob_1_5_3_data stag_prob_2_5_3_data stride1_data stride2_data stride4_data stride8_data random0_data random1_data random2_data random0_bij_data random1_bij_data random2_bij_data random_2_flows_data random_3_flows_data random_4_flows_data hotspot_one_to_one_data'
DURATION=50

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
    sleep 3
}

for f in $INPUT_FILES;
do
        input_file=$INPUT_DIR/$f
        pref="nonblocking"
        out_dir=$OUTPUT_DIR/$pref/$f
        sudo python hedera.py -i $input_file -d $out_dir -p 0.03 -t $DURATION -n --iperf
done

for f in $INPUT_FILES;
do
        input_file=$INPUT_DIR/$f
        pref="fattree-ecmp"
        out_dir=$OUTPUT_DIR/$pref/$f
        kill_pox
        start_pox DCController
        sudo python hedera.py -i $input_file -d $out_dir -p 0.03 -t $DURATION --ecmp --iperf
done

for f in $INPUT_FILES;
do
        input_file=$INPUT_DIR/$f
        pref="fattree-hedera"
        out_dir=$OUTPUT_DIR/$pref/$f
        kill_pox
        start_pox HController
        sudo python hedera.py -i $input_file -d $out_dir -p 0.03 -t $DURATION --hedera --iperf
done

kill_pox
