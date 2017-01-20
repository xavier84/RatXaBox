#!/bin/bash

INCLUDES="includes"
. "$INCLUDES"/variables.sh
. "$INCLUDES"/langues.sh
. "$INCLUDES"/functions.sh

clear
. "$INCLUDES"/logo.sh


# choix de streaming
	echo "" ; set "234" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
	set "236" "810" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #plex
	set "238" "812" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #emby
	set "240" "814" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #openvpn
	set "242" "820" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #filebot
	set "818" "258" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #sortir
	set "260" ; FONCTXT "$1" ; echo -n -e "${CBLUE}$TXT1 ${CEND}"
	read -r CHOIXS


#plex ou emby
	case $CHOIXS  in
		1)
			if [[ $VERSION =~ 7. ]]; then
				echo "deb http://shell.ninthgate.se/packages/debian wheezy main" | tee -a /etc/apt/sources.list.d/plexmediaserver.list
			elif [[ $VERSION =~ 8. ]]; then
				echo "deb http://shell.ninthgate.se/packages/debian jessie main" | tee -a /etc/apt/sources.list.d/plexmediaserver.list
			fi
			curl http://shell.ninthgate.se/packages/shell.ninthgate.se.gpg.key | apt-key add -
			aptitude update && aptitude install -y plexmediaserver && service plexmediaserver start
			#ajout icon de plex
			git clone https://github.com/xavier84/linkplex /var/www/rutorrent/plugins/linkplex
			chown -R "$WDATA" /var/www/rutorrent/plugins/linkplex
		;;

		2)
			aptitude install -y  mono-xsp4
			wget http://download.opensuse.org/repositories/home:emby/Debian_8.0/Release.key
			apt-key add - < Release.key
			apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
			#ajout depot
			echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-xamarin.list
			echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list
			echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list
			echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_8.0/ /' >> /etc/apt/sources.list.d/emby-server.list
			aptitude update
			aptitude install -y mono-complete
			aptitude install -y emby-server
			#ajout icon de emby
			git clone https://github.com/xavier84/linkemby /var/www/rutorrent/plugins/linkemby
			chown -R "$WDATA" /var/www/rutorrent/plugins/linkemby
		;;


		3)
			wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/openvpn/openvpn-install.sh
			chmod +x openvpn-install.sh && ./openvpn-install.sh
		;;

		4)
			wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/filebot/filebot.sh
			chmod +x filebot.sh && ./filebot.sh
		;;

		0)
			echo ""
		;;

		*)
			echo "" ; set "292" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
		;;
	esac