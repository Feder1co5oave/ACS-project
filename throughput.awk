BEGIN {
    sum = 0
    tot = 0
    delta = 0.25
    start = 0.5 - delta  
}

{
    if( ($1=="r") && ($3==3) && ($4==4) && ($10==s) ) {
        tot += $6
        if ( $2 <= start + delta ) {
            sum += $6
        } else {
            print start+delta, sum/delta*8/1000
            while ( $2 > start+delta ) {
                start += delta
            }
            sum = $6
        }
    }
}

END {
    print start+delta, sum/delta*8/1000
    printf("\n# average throughput = %.2f kbps\n", (tot/(start+delta))*(8/1000));
}
