set title 'Congestion window'
set xlabel 'time'
set ylabel 'cwnd (segments)'
set terminal pngcairo size 600,400 font 'Helvetica,10'
set output out
plot "./cwnd.tr" using 1:2 title "TCP lin" with points lc rgb "blue", "./cwnd.tr" using 1:3 title "TCP full" with points lc rgb "green"