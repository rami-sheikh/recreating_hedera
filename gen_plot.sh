
for i in `seq 4 2 6`; do
for NAME in `ls outs/k$i`; do
	INPUT="outs/k$i/$NAME"
	OUTPUT="pics2/k$i/$NAME"
	python plot_rate.py --input $INPUT --out $OUTPUT -k $i
done
done
