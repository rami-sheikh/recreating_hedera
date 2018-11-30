#!/bin/bash

if [ $# -eq 0 ] || [ $1 = "-h" ]
	then
		echo "Usage: ./run_network.sh controller_name topology_name fattree_name number_of_pods routing"
		echo "Note: Remove the .py extension when adding controller/topology names"
		echo "Example: ./run_network DCController DCTopo ft 4 ECMP"

else
		echo "Running network with controller $1 and topology $2..."
		~/pox/pox.py $1 --topo=$3,$4 --routing=$5
		sleep 3
		sudo mn --custom $2.py --topo fattree --controller remote
fi
