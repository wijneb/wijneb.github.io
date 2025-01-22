#!/bin/sh

# firefox profiles prof1 tm 4 are already set outside this sh script 
# window ids WID1 tm 4 are fetched then rotated and then reloaded after some time
# initieel laden de urls met 8 sec ertussen, daarna roteren de 4 urls elke om de i=5 sec.
# de 4 urls roteren in totaal x=30 keer dus totaal 30x4x5sec=600 sec waarna de urls refreshen.

url1="https://trackman.page.link/ERdao?nocache=123456"; 
url2="https://trackman.page.link/95pmR?nocache=123456"; 
url3="https://trackman.page.link/X31Rw?nocache=123456"; 
url4="https://trackman.page.link/daXw2?nocache=123456"; 

main(){ initiate; while true; do rotate; refresh_urls; done; }

FF(){ nohup firefox -P $1 --kiosk --no-remote $2 &> /dev/null & PID=$!; sleep 8; getWID; }

getWID(){ WID=$(xdotool search --pid $PID | tail -n 1); }

activWID(){ xdotool windowactivate $1; sleep 5; }

reload(){ xdotool windowactivate $1; xdotool key ctrl+l; xdotool type $2               
          xdotool key Return ; xdotool key F11; sleep 8; }

initiate(){ for i in $(seq 4); do eval url=\$url$i; FF prof$i $url; eval WID$i=\$WID; done; }

rotate(){ for x in $(seq 30); do for i in $(seq 4); do eval WID=\$WID$i; activWID $WID; done; done; }

refresh_urls(){ for i in $(seq 4); do eval url=\$url$i; eval WID=\$WID$i; reload $WID $url; done; }

main
