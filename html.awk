#!/usr/bin/awk -f 

BEGIN { print "<html><head></head><body>" } 

{print "<br>" $0}

END { print "</body></html>"}
