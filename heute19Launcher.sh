# Easy stram todays news
# usage
# bash ~/Programmierung/heuteZensiert/heute19Launcher.sh hjo


#vlc -f https://download.zdf.de/mp4/zdf/`date +%y`/`date +%m`/`date +%y%m%d`_h19/1/`date +%y%m%d`_h19_3296k_p15v13.mp4
#$1_h19
url=(http://download.zdf.de/mp4/zdf/`date +%y`/`date +%m`/`date +%y%m%d`_$1/1/`date +%y%m%d`_$1"_3296k_p15v13.mp4")
vlc -f $url

