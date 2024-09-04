#!/bin/sh

myoffset() {

    offset=$(awk -F= /SUNSET/'{print $2}' hal_1.ini)   # 01:30

    hrs=$(echo $offset | awk -F: '{print $1}')         # 01
    min=$(echo $offset | awk -F: '{print $2}') 

    hrs1=$(echo "scale=2 ; $hrs*3600" | bc)            # 3600 sec
    min1=$(echo "scale=2 ; $min*60" | bc)              # 1800 sec

    offset=$(($hrs1 + $min1))                          # 5400 sec
    
    echo "offset=$offset" > offset
}

testing() {    
    echo " in file offset: offset=$offset"
}

myoffset
testing