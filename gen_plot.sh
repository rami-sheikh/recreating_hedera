
for NAME in `ls outs/k4`; do
	INPUT="outs/k4/$NAME"
	OUTPUT="pics2/k4/$NAME"
	python plot_rate.py --input $INPUT --out $OUTPUT -k 4
done
