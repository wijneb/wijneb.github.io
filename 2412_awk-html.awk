#!/usr/bin/awk -f 

BEGIN { print "<!DOCTYPE html><html><head></head><body>" } 

{print "<br>" $0}

END { print "</body></html>"}
