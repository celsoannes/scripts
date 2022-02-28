#!/bin/bash


NF="0"
i="1"
URL="https://iptvcat.com/brazil"


while [ "$NF" = "0" ]
do

   wget "$URL/$i" -O html_$i.tmp
   NF=`grep 'Nothing found' html_$i.tmp | wc -l`

   echo "Nothing found: $NF"

   grep -v 'Download list' html_$i.tmp | egrep '\.m3u8' | grep -o -P '(?<=href=").*(?="\ )' > m3u8_$i.tmp
   grep 'state span' html_$i.tmp | grep -o -P "(title=').*(e)" | awk -F"'" '{print $2}' > state_$i.tmp
   paste m3u8_$i.tmp state_$i.tmp | grep Online > online_$i.tmp
   cat online_* | awk '{print $1}' > lista.tmp
#   grep 'channel_name' html_$i.tmp --color | grep -v data | grep -o -P "(>).*(<)" | sed 's/>//g' | sed 's/<//g' > channel_name_$i.tmp

   i=$((i+1))
done

wget -i lista.tmp
cat *.m3u8 > lista.m3u8
sed -i s/#EXTM3U//g lista.m3u8
sed -i '/^$/d' lista.m3u8
sed -i '1s/^/#EXTM3U\n/' lista.m3u8

cat lista.m3u8 > /var/www/html/lista.m3u8
