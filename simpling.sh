#!/bin/bash

myvar1=$1
myvar2=$2
myvar3="
\n This is simpling.sh. Two inputs are required, \n 
1: the input file \n 2: one of the functions below: \n 
(dedup, awkfile, tags, headers, cats, tagshort, or shotags). \n 
All functions use lowercase and mytags deduplicates. \n 
The simple file needs to be in the folder (matching key;value pairs). \n
No or wrong input will show this text. \n 
Results will show in this terminal and can be redirected \n 
to a file using the redirect construct: > file. \n 
Input and output seperators are semicolons. \n 
For terminal presentation the pipe \"|\" to the column -ts\";\" \n 
functionality or to sort -nr functionality might be used \n 
(n is numerical, r is reversed order). \n 
Grep functionality might also be used to grep a subset from the output. \n 
LUsimple.awk is required for tags, cats and tagshort functions. \n 
Here's how u make it: sh simpling.sh simple simplawk > LUsimple.awk \n 
Here are some other example instructions that might be helpfull: \n 
(simple and ING2022e.csv are example input files) \n\n
sh simpling.sh \n
sh simpling.sh simple dedup \n
sh simpling.sh simple awkfile \n
sh simpling.sh ING2022e.csv tags \n
sh simpling.sh ING2022e.csv headers \n
sh simpling.sh ING2022e.csv shotags \n
sh simpling.sh ING2022e.csv cats | sort -n | column -ts\";\" \n
sh simpling.sh ING2022e.csv tagshort | sort -n | column -ts\";\" \n
sh simpling.sh ING2022e.csv tagshort | sort | column -ts\";\" | grep bij \n
"

inpt()   { cat $myvar1 ; }
dedupl() { awk '!visited[$0]++' ; }
shotags(){ awk '{print $11}' FS=";" ; }
tolower(){ awk '{print tolower($0)}' ; }
tagshrt(){ awk 'NR>1{print $11,$7,$1,$2}' FS=";" OFS=";" ; }
simpl()  { awk '{print "/"$1"/{myvar=\""$2"\"}"}' FS=";" ; }
header() { awk 'NR==1 { for (i=1; i<NF+1; i++) print "$"i, $i; exit }'  FS=";" ; }
catcalc(){ awk -v taf='total-af' -v tbij='totaal-bij' ' 
           NR>1{ cats[$11]+=$7; if($6=="af") cats[taf]+=$7; else cats[tbij]+=$7 } 
           END{ for (key in cats) print cats[key],key }' FS=";" OFS=";" ; }
awkfile(){ echo "awk '{myvar=\"diverse\"}" 
           echo "$( cat simple | tolower | dedupl | simpl )"
           echo "{\$11=myvar\"-\"\$6; print \$0} ' FS=';' OFS=';' " ; }
mytags() { eval "$(awkfile)" ; }

case $myvar2 in
  headers)  inpt | tolower | header ;;
  dedup)    inpt | tolower | dedupl ;;
  tags)     inpt | tolower | mytags ;;
  cats)     inpt | tolower | mytags | catcalc ;;
  tagshort) inpt | tolower | mytags | tagshrt ;;
  shotags)  inpt | tolower | mytags | shotags ;;
  awkfile)  awkfile ;;
  *) echo $myvar3 ;;
esac
