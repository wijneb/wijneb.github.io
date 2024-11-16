#!/bin/bash

myvar1=$1
myvar2=$2
myvar3="
This is simpling.sh, two inputs are required, 1: the input file, (note that the input file needs to be converted first with the tolower function) and 2: one of the functions: tags, tagshort, cats, tolower, headers, deduplicate or simplawk. No or wrong input will show this text. Results will show in this terminal and can be redirected to a file using (in the terminal) the redirect construct: > file. Input and output seperators are semicolons. Note that the simplawk output needs the first line awk shebang (#!/usr/bin/awk -f) to be added and at the end the actual functionality {\$11=myvar\"-\"\$6; print \$0} needs to be added. For terminal presentation the pipe \"|\" to the column -ts\";\" bash/awk functionality might be used, also pipe to sort -nr functionality might be used (n is numerical, r is reversed order). Grep functionality might also be used to grep a subset from the output. Here are som instructions that might be helpfull: \n
sh simpling.sh \n
sh simpling.sh ING2022e.csv headers \n
sh simpling.sh ING2022e.csv tolower > L_ING2022.csv \n
sh simpling.sh L_ING2022.csv tags > L_ING2022withTags.csv \n
sh simpling.sh L_ING2022.csv cats | sort -n | column -ts\";\" \n
sh simpling.sh L_ING2022.csv tagshort | grep belasting-af \n
sh simpling.sh L_ING2022.csv tagshort | sort | column -ts\";\" | grep bij
"

tags(){ awk -f LUsimple.awk $myvar1 ; }
tagshort(){ tags | awk 'NR>1{print $11,$7,$1,$2}' FS=";" OFS=";" ; }
tolower(){ awk '{print tolower($0)}' $myvar1 ; }
simplawk(){ awk '{print "/"$1"/{myvar=\""$2"\"}"}' FS=";" $myvar1 ; }
deduplicate(){ awk '!visited[$0]++' $myvar1 ; }

headers(){ awk 'NR==1 { for (i=1; i<NF+1; i++) 
                print "$"i, $i; exit}'  FS=";"  $myvar1 ; }

cats(){ tags | awk 'NR>1 { myarr[$11]+=$7 
                    if($6=="af") totaf+=$7; else totbij+=$7 }
                    END{ for (key in myarr) print myarr[key], key  
                         print totaf, "totaal-af" 
                         print totbij, "totaal-bij" } ' \
                    FS=";" OFS=";" ; }

case $myvar2 in
  tags) tags ;;
  cats) cats ;;
  headers) headers ;;
  tolower) tolower ;;
  tagshort) tagshort ;;
  simplawk) simplawk ;;
  deduplicate) deduplicate ;;
  *) echo $myvar3 ;;
esac
