set title 'Sequence number'
set xlabel 'time'
set ylabel 'seq# (bytes)'
set terminal pngcairo size 600,400 font 'Helvetica,10'
set output out
plot "./seqnt.tr" using 1:2 title "TCP lin" with points lc rgb "blue", "./seqnt.tr" using 1:3 title "TCP full" with points lc rgb "green"