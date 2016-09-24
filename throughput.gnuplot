set title 'Throughput'
set xlabel 'time'
set ylabel 'throughput (kbps)'
set terminal pngcairo size 600,400 font 'Helvetica,10'
set output out
#plot "./thrut.tr" using 1:($2/1000) title "TCP lin", "./thrut.tr" using 1:($3/1000) title "TCP full"
plot "./thrut1.tr" title "TCP lin" with points lc rgb "blue", "./thrut2.tr" title "TCP full" with points lc rgb "green", "./thrut3.tr" title "CBR" with points lc rgb "orange"