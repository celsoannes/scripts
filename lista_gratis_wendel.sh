#!/bin/bash

URL="https://wendeltecksempre.blogspot.com/2019/12/lista-httpbit.html"

wget "$URL" -O /tmp/wendeltecksempre.html
grep 'bit.ly' /tmp/wendeltecksempre.html | egrep -o "(http(s)?://){1}[^'\"]+" | grep span | cut -c1-22 > /tmp/wendeltecksempre.txt
LINHAS=$(cat /tmp/wendeltecksempre.txt | wc -l)

mkdir -p lista
rm lista/*

x=1
while [ $x -le $LINHAS ]
do
  #echo "Welcome $x times"
  M3U8=$(sed "$x!d" /tmp/wendeltecksempre.txt)
#  echo "$x - $LINHAS $M3U8"
  wget $M3U8 -O lista/$x.m3u8



  x=$(( $x + 1 ))
done

diff -D  lista/*.m3u8 > lista_gratis.m3u8

#cleaning file
sed -i '/#endif/d' lista_gratis.m3u8
sed -i '/#ifndef/d' lista_gratis.m3u8
sed -i '/#else/d' lista_gratis.m3u8

sed -i 's/\^M//g' lista_gratis.m3u8

dos2unix lista_gratis.m3u8


############################################## FAV

FAV=/var/www/html/favoritos.m3u8
FAV_FILE=favoritos.txt
FAV_LINES=favoritos/fav_lines.txt
FULL_M3U8=lista_gratis.m3u8
LINHAS=$(cat $FAV_FILE | wc -l)


mkdir -p favoritos
rm favoritos/*
> $FAV

x=1
while [ $x -le $LINHAS ]
do
  #load channel name
  fav_channel=$(sed "$x!d" $FAV_FILE)

  #store fav number lines
  grep -inF "$fav_channel" $FULL_M3U8 | awk -F':' '{print $1}' >> $FAV_LINES

  x=$(( $x + 1 ))
done


#create m3u
LINHAS=$(cat $FAV_LINES | wc -l)
x=1
while [ $x -le $LINHAS ]
do

  EXTINF=$(sed "$x!d" $FAV_LINES)
  HTTP=$(( $EXTINF + 1 ))

  sed "$EXTINF!d" $FULL_M3U8 >> $FAV
  sed "$HTTP!d" $FULL_M3U8 >> $FAV

  x=$(( $x + 1 ))
done

#sed -i 's/\^M//g' /var/www/html/favoritos.m3u8


#cat -v lista/*.m3u8 > /var/www/html/lista_gratis.m3u8
#cat -v lista/*.m3u8 > lista_gratis.m3u8
#EXTM3U

sed -i ' 1 s/^/&#EXTM3U\n/' $FAV
