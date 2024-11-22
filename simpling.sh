#!/bin/bash

myvar1=$1
myvar2=$2
myvar3="
\n This is simpling.sh. Two inputs are required, \n 
1: the input file \n 2: one of the functions below: \n 
(dedup, simplawk, headers, tags, tagshort or cats). \n 
All functions use lowercase and simplawk deduplicates. \n 
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
sh simpling.sh simple simplawk \n
sh simpling.sh ING2022e.csv tags \n
sh simpling.sh ING2022e.csv headers \n
sh simpling.sh ING2022e.csv cats | sort -n | column -ts\";\" \n
sh simpling.sh ING2022e.csv tagshort | sort -n | column -ts\";\" \n
sh simpling.sh ING2022e.csv tagshort | sort | column -ts\";\" | grep bij \n
"

inpt()   { cat $myvar1 ; }
mytags() { awk -f LUsimple.awk ; }
dedupl() { awk '!visited[$0]++' ; }
tolower(){ awk '{print tolower($0)}' ; }
short()  { awk 'NR>1{print $11,$7,$1,$2}' FS=";" OFS=";" ; }
simpl()  { awk '{print "/"$1"/{myvar=\""$2"\"}"}' FS=";" ; }
header() { awk 'NR==1 { for (i=1; i<NF+1; i++) print "$"i, $i; exit }'  FS=";" ; }
sawk()   { mystt='#!/usr/bin/awk -f \n' ; myend='\n{$11=myvar"-"$6; print $0}' 
           awk -v mystt="$mystt" -v myend="$myend" \
               'BEGIN{print mystt} {print} END{print myend}' FS=";" OFS=";" ; }
catcalc(){ awk 'NR>1 { myarr[$11]+=$7 
                if($6=="af") totaf+=$7; else totbij+=$7 }
                END{ for (key in myarr) print myarr[key], key  
                     print totaf, "totaal-af" 
                     print totbij, "totaal-bij" } ' FS=";" OFS=";" ; }

case $myvar2 in
  headers)  inpt | tolower | header ;;
  tags)     inpt | tolower | mytags ;;
  cats)     inpt | tolower | mytags | catcalc ;;
  tagshort) inpt | tolower | mytags | short ;;
  simplawk) inpt | tolower | dedupl | simpl | sawk ;;
  dedup)    inpt | tolower | dedup1 ;;
  *) echo $myvar3 ;;
esac
