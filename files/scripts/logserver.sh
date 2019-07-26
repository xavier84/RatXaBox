#!/bin/bash
#
CMDLOGSERVER=$(/usr/bin/lsb_release -cs)

if [[ "$CMDLOGSERVER" == buster ]]; then
	CMDCP="/usr/bin/cp"
	CMDCAT="/usr/bin/cat"
	CMDSED="/usr/bin/sed"
	CMDCCZE="/usr/bin/ccze"

elif [[ "$CMDLOGSERVER" == stretch ]]; then
	CMDCP="/bin/cp"
	CMDCAT="/bin/cat"
	CMDSED="/bin/sed"
	CMDCCZE="/usr/bin/ccze"
fi


if [ -e /var/log/nginx/rutorrent-access.log.1 ]; then
	# Récupération des logs (J et J-1) et fusion
	"$CMDCP" /var/log/nginx/rutorrent-access.log /tmp/access.log.0
	"$CMDCP" /var/log/nginx/rutorrent-access.log.1 /tmp/access.log.1
	cd /tmp
	"$CMDCAT" access.log.1 access.log.0 > access.log
else
	cd /tmp
	"$CMDCP" /var/log/nginx/rutorrent-access.log /tmp/access.log
fi

"$CMDSED" -i '/plugins/d' access.log
"$CMDSED" -i '/getsettings.php/d' access.log
"$CMDSED" -i '/setsettings.php/d' access.log
"$CMDSED" -i '/@USERMAJ@\ HTTP/d' access.log
"$CMDCCZE" -h < /tmp/access.log > @RUTORRENT@/logserver/access.html
