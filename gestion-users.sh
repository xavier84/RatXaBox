#!/bin/bash

################################################
# lancement gestion des utilisateurs ruTorrent #
################################################


# contrôle installation
if [ ! -f "$RUTORRENT"/histo.log ]; then
	echo ""; set "220"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
	set "222"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"; echo ""
	exit 1
fi

# test si ratxabox 9
if [ ! -f "$RUTORRENT"/ratxabox9.txt ]; then
	echo ""
	echo ""; set "866"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"; echo ""
	echo ""
	echo "cd /tmp"
	echo "rm -rf ratxabox"
	echo "git clone https://github.com/xavier84/RatXaBox7-8 ratxabox"
	echo "cd ratxabox"
	echo "chmod a+x bonobox.sh && ./bonobox.sh"
	echo ""
	exit 1
fi

# message d'accueil
clear
echo ""; set "224"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

# mise en garde
echo ""; set "226"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
set "228"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
set "230"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
echo ""; set "232"; FONCTXT "$1"; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r VALIDE

if FONCNO "$VALIDE"; then
	echo ""; set "210"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
	echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; echo ""
	exit 1
fi

if FONCYES "$VALIDE"; then
	# boucle ajout/suppression utilisateur
	while :; do
		# menu gestion multi-utilisateurs
		echo ""; set "234"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
		echo ""
		echo -e "${CMAG}*****Bonobox*****${CEND}"
		set "236" "248"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "238" "250"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "240" "252"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "242" "254"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "244" "256"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "246" "296"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "294" "258"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		echo ""
		echo -e "${CMAG}*****RatXaBox*****${CEND}"
		set "836" "810" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #plex 50
		set "838" "812" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #emby 51
		set "840" "814" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #openvpn 52
		set "842" "820" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #filebot 53
		set "844" "822" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #SyncThing 54
		set "846" "824" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #sickrage 55
		set "848" "826" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #couchpotato 56
		set "850" "828" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #medusa 57
		set "852" "834" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #esm 58
		set "854" "864" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #jackett 59
		set "260"; FONCTXT "$1"; echo -n -e "${CBLUE}$TXT1 ${CEND}"
		read -r OPTION

		case $OPTION in
			1) # ajout utilisateur
				FONCUSER # demande nom user
				echo ""
				FONCPASS # demande mot de passe

				# récupération 5% root sur /home/user si présent
				FONCFSUSER "$USER"

				# variable email (rétro compatible)
				TESTMAIL=$(sed -n "1 p" "$RUTORRENT"/histo.log)
				if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
					EMAIL="$TESTMAIL"
				else
					EMAIL=contact@exemple.com
				fi

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# ajout utilisateur
				useradd -M -s /bin/bash "$USER"

				# création mot de passe utilisateur
				echo "${USER}:${USERPWD}" | chpasswd

				# anti-bug /home/user déjà existant
				mkdir -p /home/"$USER"
				chown -R "$USER":"$USER" /home/"$USER"

				# variable utilisateur majuscule
				USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

				# récupération ip serveur
				FONCIP

				su "$USER" -c 'mkdir -p ~/watch ~/torrents ~/.session ~/.backup-session'

				# calcul port
				FONCPORT "$RUTORRENT" 5001

				# configuration munin
				FONCMUNIN "$USER" "$PORT"

				# configuration .rtorrent.rc
				FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

				# configuration user rutorrent.conf
				sed -i '$d' "$NGINXENABLE"/rutorrent.conf
				FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

				# configuration logserver
				sed -i '$d' "$SCRIPT"/logserver.sh
				echo "sed -i '/@USERMAJ@\ HTTP/d' access.log" >> "$SCRIPT"/logserver.sh
				sed -i "s/@USERMAJ@/$USERMAJ/g;" "$SCRIPT"/logserver.sh
				echo "ccze -h < /tmp/access.log > $RUTORRENT/logserver/access.html" >> "$SCRIPT"/logserver.sh

				# configuration script backup .session (rétro-compatibilité)
				if [ -f "$SCRIPT"/backup-session.sh ]; then
					FONCBAKSESSION
				fi

				# config.php
				mkdir "$RUCONFUSER"/"$USER"
				FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

				# plugins.ini
				cp -f "$FILES"/rutorrent/plugins.ini "$RUCONFUSER"/"$USER"/plugins.ini
				cat <<- EOF >> "$RUCONFUSER"/"$USER"/plugins.ini
					[linklogs]
					enabled = no
				EOF

				# configuration autodl-irssi
				if [ -f "/etc/irssi.conf" ]; then
					FONCIRSSI "$USER" "$PORT" "$USERPWD"
				fi

				# chroot user supplémentaire
				cat <<- EOF >> /etc/ssh/sshd_config
					Match User $USER
					ChrootDirectory /home/$USER
				EOF

				FONCSERVICE restart ssh

				# permissions
				chown -R "$WDATA" "$RUTORRENT"
				chown -R "$USER":"$USER" /home/"$USER"
				chown root:"$USER" /home/"$USER"
				chmod 755 /home/"$USER"

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# htpasswd
				FONCHTPASSWD "$USER"

				# seedbox-manager configuration user
				cd "$SBMCONFUSER" || exit
				mkdir "$USER"
				if [ ! -f "$SBM"/sbm_v3 ]; then
					cp -f "$FILES"/sbm_old/config-user.ini "$SBMCONFUSER"/"$USER"/config.ini
				else
					cp -f "$FILES"/sbm/config-user.ini "$SBMCONFUSER"/"$USER"/config.ini
				fi

				sed -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/https:\/\/graph.domaine.fr/..\/graph\/$USER.php/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/RPC1/$USERMAJ/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/contact@mail.com/$EMAIL/g;" "$SBMCONFUSER"/"$USER"/config.ini

				chown -R "$WDATA" "$SBMCONFUSER"

				# configuration page index munin
				FONCGRAPH "$USER"
				FONCSERVICE start "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE start "$USER"-irssi
				fi

				# log users
				echo "userlog">> "$RUTORRENT"/histo.log
				sed -i "s/userlog/$USER:$PORT/g;" "$RUTORRENT"/histo.log
				FONCSERVICE restart nginx
				echo ""; set "218"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""
				set "182"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"; echo ""
			;;

			2) # suspendre utilisateur
				echo ""; set "214"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER

				# variable email (rétro compatible)
				TESTMAIL=$(sed -n "1 p" "$RUTORRENT"/histo.log)
				if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
					EMAIL="$TESTMAIL"
				else
					EMAIL=contact@exemple.com
				fi

				# récupération ip serveur
				FONCIP

				# variable utilisateur majuscule
				USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

				echo ""; set "262"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""

				# crontab (pour retro-compatibilité)
				crontab -l > /tmp/rmuser
				sed -i "s/* \* \* \* \* if ! ( ps -U $USER | grep rtorrent > \/dev\/null ); then \/etc\/init.d\/$USER-rtorrent start; fi > \/dev\/null 2>&1//g;" /tmp/rmuser
				crontab /tmp/rmuser
				rm /tmp/rmuser

				update-rc.d "$USER"-rtorrent remove

				# contrôle présence utilitaire
				if [ ! -f "$NGINXBASE"/aide/contact.html ]; then
					cd /tmp || exit
					wget http://www.bonobox.net/script/contact.tar.gz
					tar xzfv contact.tar.gz
					cp -f /tmp/contact/contact.html "$NGINXBASE"/aide/contact.html
					cp -f /tmp/contact/style/style.css "$NGINXBASE"/aide/style/style.css
				fi

				# page support
				cp -f "$NGINXBASE"/aide/contact.html "$NGINXBASE"/"$USER".html
				sed -i "s/@USER@/$USER/g;" "$NGINXBASE"/"$USER".html
				chown -R "$WDATA" "$NGINXBASE"/"$USER".html

				# seedbox-manager service minimum
				mv "$SBMCONFUSER"/"$USER"/config.ini "$SBMCONFUSER"/"$USER"/config.bak
				if [ ! -f "$SBM"/sbm_v3 ]; then
					cp -f "$FILES"/sbm_old/config-mini.ini "$SBMCONFUSER"/"$USER"/config.ini
				else
					cp -f "$FILES"/sbm/config-mini.ini "$SBMCONFUSER"/"$USER"/config.ini
				fi

				sed -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/https:\/\/rutorrent.domaine.fr/..\/$USER.html/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/https:\/\/graph.domaine.fr/..\/$USER.html/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/RPC1/$USERMAJ/g;" "$SBMCONFUSER"/"$USER"/config.ini
				sed -i "s/contact@mail.com/$EMAIL/g;" "$SBMCONFUSER"/"$USER"/config.ini

				chown -R "$WDATA" "$SBMCONFUSER"

				# stop user
				FONCSERVICE stop "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE stop "$USER"-irssi
				fi
				killall --user "$USER" rtorrent
				killall --user "$USER" screen
				mv /home/"$USER"/.rtorrent.rc /home/"$USER"/.rtorrent.rc.bak
				usermod -L "$USER"

				echo ""; set "264" "268"; FONCTXT "$1" "$2"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
			;;

			3) # rétablir utilisateur
				echo ""; set "214"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"
				read -r USER
				echo ""; set "270"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""

				mv /home/"$USER"/.rtorrent.rc.bak /home/"$USER"/.rtorrent.rc
				# remove ancien script pour mise à jour init.d
				update-rc.d "$USER"-rtorrent remove

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# start user
				rm /home/"$USER"/.session/rtorrent.lock >/dev/null 2>&1
				FONCSERVICE start "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE start "$USER"-irssi
				fi
				usermod -U "$USER"

				# seedbox-manager service normal
				rm "$SBMCONFUSER"/"$USER"/config.ini
				mv "$SBMCONFUSER"/"$USER"/config.bak "$SBMCONFUSER"/"$USER"/config.ini
				chown -R "$WDATA" "$SBMCONFUSER"
				rm "$NGINXBASE"/"$USER".html

				echo ""; set "264" "272"; FONCTXT "$1" "$2"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
			;;

			4) # modification mot de passe utilisateur
				echo ""; set "214"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				echo ""; FONCPASS

				echo ""; set "276"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# modification du mot de passe
				echo "${USER}:${USERPWD}" | chpasswd

				# htpasswd
				FONCHTPASSWD "$USER"

				echo ""; set "278" "280"; FONCTXT "$1" "$2"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				echo
				set "182"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1${CEND}"; echo ""
			;;

			5) # suppression utilisateur
				echo ""; set "214"; FONCTXT "$1"; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				echo ""; set "282" "284"; FONCTXT "$1" "$2"; echo -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CGREEN}$TXT2 ${CEND}"
				read -r SUPPR

				if FONCNO "$SUPPR"; then
					echo
				else
					set "286"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"; echo ""

					# variable utilisateur majuscule
					USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

					# suppression conf munin
					rm "$GRAPH"/img/rtom_"$USER"_*
					rm "$GRAPH"/"$USER".php

					sed -i "/rtom_${USER}_peers.graph_width 700/,+8d" /etc/munin/munin.conf
					sed -i "/\[rtom_${USER}_\*\]/,+6d" /etc/munin/plugin-conf.d/munin-node

					rm /etc/munin/plugins/rtom_"$USER"_*
					rm "$MUNIN"/rtom_"$USER"_*
					rm "$MUNINROUTE"/rtom_"$USER"_*

					FONCSERVICE restart munin-node

					# crontab (pour rétro-compatibilité)
					crontab -l > /tmp/rmuser
					sed -i "s/* \* \* \* \* if ! ( ps -U $USER | grep rtorrent > \/dev\/null ); then \/etc\/init.d\/$USER-rtorrent start; fi > \/dev\/null 2>&1//g;" /tmp/rmuser
					crontab /tmp/rmuser
					rm /tmp/rmuser

					# stop utilisateur
					FONCSERVICE stop "$USER"-rtorrent
					if [ -f "/etc/irssi.conf" ]; then
						FONCSERVICE stop "$USER"-irssi
					fi
					killall --user "$USER" rtorrent
					killall --user "$USER" screen

					# suppression script
					if [ -f "/etc/irssi.conf" ]; then
						rm /etc/init.d/"$USER"-irssi
						update-rc.d "$USER"-irssi remove
					fi
					rm /etc/init.d/"$USER"-rtorrent
					update-rc.d "$USER"-rtorrent remove

					# supression rc.local (pour rétro-compatibilité)
					sed -i "/$USER/d" /etc/rc.local 2>/dev/null

					# suppression configuration rutorrent
					rm -R "${RUCONFUSER:?}"/"$USER"
					rm -R "${RUTORRENT:?}"/share/users/"$USER"

					# suppression mot de passe
					sed -i "/^$USER/d" "$NGINXPASS"/rutorrent_passwd
					rm "$NGINXPASS"/rutorrent_passwd_"$USER"

					# suppression nginx
					sed -i '/location \/'"$USERMAJ"'/,/}/d' "$NGINXENABLE"/rutorrent.conf
					FONCSERVICE restart nginx

					# suppression seedbox-manager
					rm -R "${SBMCONFUSER:?}"/"$USER"

					# suppression backup .session (rétro-compatibilité)
					if [ -f "$SCRIPT"/backup-session.sh ]; then
						sed -i "/backup $USER/d" "$SCRIPT"/backup-session.sh
					fi

					# suppression utilisateur
					deluser "$USER" --remove-home

					echo ""; set "264" "288"; FONCTXT "$1" "$2"; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				fi
			;;

			6) # debug
				chmod a+x "$FILES"/scripts/check-rtorrent.sh
				bash "$FILES"/scripts/check-rtorrent.sh
			;;

			7) # sortir gestion utilisateurs
				echo ""; set "290"; FONCTXT "$1"; echo -n -e "${CGREEN}$TXT1 ${CEND}"
				read -r REBOOT

				if FONCNO "$REBOOT"; then
					FONCSERVICE restart nginx &> /dev/null
					echo ""; set "200"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
					echo ""; set "210"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
					echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; echo ""
					exit 1
				fi

				if FONCYES "$REBOOT"; then
					echo ""; set "210"; FONCTXT "$1"; echo -e "${CBLUE}$TXT1${CEND}"
					echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; echo ""
					reboot
				fi
				break
			;;

			50)
				apt-get install apt-transport-https -y
				echo "deb https://downloads.plex.tv/repo/deb/ public main" > /etc/apt/sources.list.d/plexmediaserver.list
				wget -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | apt-key add -
				aptitude update && aptitude install -y plexmediaserver && service plexmediaserver start
				#ajout icon de plex
				if [ ! -d "$RUPLUGINS"/linkplex ];then
					git clone https://github.com/xavier84/linkplex "$RUPLUGINS"/linkplex
					chown -R "$WDATA" "$RUPLUGINS"/linkplex

				fi
			;;

			51)
				if [[ $VERSION =~ 7. ]]; then
					echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list
					echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list
					echo "deb http://download.mono-project.com/repo/debian wheezy main" > /etc/apt/sources.list.d/mono-official.list
					echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_7.0/ /' > /etc/apt/sources.list.d/emby-server.list
					wget -nv http://download.opensuse.org/repositories/home:emby/Debian_7.0/Release.key -O Release.key
					apt-key add - < Release.key
					apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
				elif [[ $VERSION =~ 8. ]]; then
					echo "deb http://download.mono-project.com/repo/debian jessie main" > /etc/apt/sources.list.d/mono-official.list
					echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_8.0/ /' > /etc/apt/sources.list.d/emby-server.list
					wget http://download.opensuse.org/repositories/home:emby/Debian_8.0/Release.key -O Release.key
					apt-key add - < Release.key
					apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
				elif [[ $VERSION =~ 9. ]]; then
					echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_9.0/ /' > /etc/apt/sources.list.d/emby-server.list
					wget http://download.opensuse.org/repositories/home:emby/Debian_9.0/Release.key -O Release.key
					apt-key add - < Release.key
				fi

				aptitude update
				aptitude install -y  mono-xsp4 emby-server
				#ajout icon de emby
				if [ ! -d "$RUPLUGINS"/linkemby ];then
					git clone https://github.com/xavier84/linkemby "$RUPLUGINS"/linkemby
					chown -R "$WDATA" "$RUPLUGINS"/linkemby
				fi
			;;


			52)
				wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/openvpn/openvpn-install.sh
				chmod +x openvpn-install.sh && ./openvpn-install.sh
			;;

			53)
				wget https://raw.githubusercontent.com/xavier84/Script-xavier/master/filebot/filebot.sh
				chmod +x filebot.sh && ./filebot.sh
			;;

			54)
				set "184" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				curl -s https://syncthing.net/release-key.txt | apt-key add -
				echo "deb http://apt.syncthing.net/ syncthing release" | tee /etc/apt/sources.list.d/syncthing.list
				apt-get update
				apt-get install syncthing

				cp -f "$FILES"/syncthing/syncthing@.service /etc/systemd/system/syncthing@"$USER".service
				mkdir -p /home/"$USER"/.config/syncthing
				chown -R "$USER":"$USER" /home/"$USER"/.config
				chmod -R 700 /home/"$USER"/.config
				systemctl enable syncthing@"$USER".service
				systemctl start syncthing@"$USER".service
				sleep 3
				sed -i -e 's/127.0.0.1/0.0.0.0/g' /home/"$USER"/.config/syncthing/config.xml
				sed -i -e '2,20d' /home/"$USER"/.config/syncthing/config.xml
				systemctl restart syncthing@"$USER".service
				cp -f "$BONOBOX"/files/syncthing/syncthing.vhost "$NGINXCONFDRAT"/syncthing.conf
				FONCSERVICE restart nginx
			;;

			55)
				set "184" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				if [ ! -d "$SICKRAGE" ];then
					apt-get install -y git-core python python-cheetah
					git clone https://github.com/SickRage/SickRage "$SICKRAGE"
					chown -R "$USER":"$USER" "$SICKRAGE"
					chmod -R 755 "$SICKRAGE"
					#compteur
					PORT=20001
					echo "$PORT" >> "$SICKRAGE"/histo.log
				fi
				# calcul port sickrage
				FONCPORT "$SICKRAGE" 20001
				#compteur
				echo "$PORT" >> "$SICKRAGE"/histo.log
				#config
				cp -f "$BONOBOX"/files/sickrage/sickrage.init /etc/init.d/sickrage-"$USER"
				chmod +x /etc/init.d/sickrage-"$USER"
				sed -i -e 's/xataz/'$USER'/g' /etc/init.d/sickrage-"$USER"
				sed -i -e 's/SR_USER=/SR_USER='$USER'/g' /etc/init.d/sickrage-"$USER"
				/etc/init.d/sickrage-"$USER" start && sleep 5 && /etc/init.d/sickrage-"$USER" stop
				sleep 1
				sed -i -e 's/web_root = ""/web_root = \/sickrage/g' "$SICKRAGE"/data/"$USER"/config.ini
				sed -i -e 's/web_port = 8081/web_port = '$PORT'/g' "$SICKRAGE"/data/"$USER"/config.ini
				sed -i -e 's/torrent_dir = ""/torrent_dir = \/home\/'$USER'\/watch\//g' "$SICKRAGE"/data/"$USER"/config.ini
				sed -i -e 's/web_host = 0.0.0.0/web_host = 127.0.0.1/g' "$SICKRAGE"/data/"$USER"/config.ini
				systemctl daemon-reload
				FONCSCRIPT "$USER" sickrage
				FONCSERVICE start sickrage-"$USER"

				if [ ! -f "$NGINXCONFDRAT"/sickrage.conf ]; then
					cp -f "$BONOBOX"/files/sickrage/sickrage.vhost "$NGINXCONFDRAT"/sickrage.conf
				else
					sed -i '$d' "$NGINXCONFDRAT"/sickrage.conf
					cat <<- EOF >> "$NGINXCONFDRAT"/sickrage.conf
					                if (\$remote_user = "@USER@") {
					                        proxy_pass http://127.0.0.1:@PORT@;
					                        break;
			    		           }
			    		  }
					EOF
				fi

				sed -i "s|@USER@|$USER|g;" "$NGINXCONFDRAT"/sickrage.conf
				sed -i "s|@PORT@|$PORT|g;" "$NGINXCONFDRAT"/sickrage.conf
				FONCSERVICE restart nginx

			;;

			56)
				set "184" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				if [ ! -d "$COUCHPOTATO" ];then
					apt-get install -y git-core python python-cheetah
					git clone https://github.com/CouchPotato/CouchPotatoServer.git "$COUCHPOTATO"
					chown -R "$USER":"$USER" "$COUCHPOTATO"
					chmod -R 755 "$COUCHPOTATO"
					#compteur
					PORT=5051
					echo "$PORT" >> "$COUCHPOTATO"/histo.log
				fi
				# calcul port sickrage
				FONCPORT "$COUCHPOTATO" 5051
				#compteur
				echo "$PORT" >> "$COUCHPOTATO"/histo.log
				#config couch
				cp -f "$BONOBOX"/files/couchpotato/ubuntu /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CONFIG=\/etc\/default\/couchpotato/#CONFIG=\/etc\/default\/couchpotato/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/# Provides:          couchpotato/# Provides:          '$USER'/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CP_USER:=couchpotato/CP_USER:='$USER'/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CP_DATA:=\/var\/opt\/couchpotato/CP_DATA:=\/opt\/couchpotato\/data\/'$USER'/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CP_PIDFILE:=\/var\/run\/couchpotato\/couchpotato.pid/CP_PIDFILE:=\/opt\/couchpotato\/data\/'$USER'\/couchpotato.pid/g' /etc/init.d/couchpotato-"$USER"
				chmod +x /etc/init.d/couchpotato-"$USER"
				systemctl daemon-reload
				FONCSCRIPT "$USER" couchpotato
				/etc/init.d/couchpotato-"$USER" start && sleep 5 && /etc/init.d/couchpotato-"$USER" stop
				sleep 1
				#config de user couch
				chmod -Rf 755  "$COUCHPOTATO"/data/
				cp -f "$BONOBOX"/files/couchpotato/settings.conf "$COUCHPOTATO"/data/"$USER"/settings.conf
				sed -i "s|@USER@|$USER|g;" "$COUCHPOTATO"/data/"$USER"/settings.conf
				sed -i "s|@PORT@|$PORT|g;" "$COUCHPOTATO"/data/"$USER"/settings.conf
				FONCSCRIPT "$USER" couchpotato
				FONCSERVICE start couchpotato-"$USER"

				if [ ! -f "$NGINXCONFDRAT"/couchpotato.conf ]; then
					cp -f "$BONOBOX"/files/couchpotato/couchpotato.vhost "$NGINXCONFDRAT"/couchpotato.conf
				else
					#config nginx couchpotato
					sed -i '$d' "$NGINXCONFDRAT"/couchpotato.conf
					cat <<- EOF >> "$NGINXCONFDRAT"/couchpotato.conf
					                if (\$remote_user = "@USER@") {
				                        proxy_pass http://127.0.0.1:@PORT@;
				                        break;
					               }
					      }
					EOF
				fi

				sed -i "s|@USER@|$USER|g;" "$NGINXCONFDRAT"/couchpotato.conf
				sed -i "s|@PORT@|$PORT|g;" "$NGINXCONFDRAT"/couchpotato.conf
				FONCSERVICE restart nginx
			;;

			57)
				set "184" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				if [ ! -d "$MEDUSA" ];then
					apt-get install -y git-core python python-cheetah
					git clone git://github.com/pymedusa/Medusa.git "$MEDUSA"
					chown -R "$USER":"$USER" "$MEDUSA"
					chmod -R 755 "$MEDUSA"
					#compteur
					PORT=5051
					echo "$PORT" >> "$MEDUSA"/histo.log
				fi
				# calcul port medusa
				FONCPORT "$MEDUSA" 20100
				#compteur
				echo "$PORT" >> "$MEDUSA"/histo.log
				#config
				cp -f "$BONOBOX"/files/medusa/medusa.init /etc/init.d/medusa-"$USER"
				chmod +x /etc/init.d/medusa-"$USER"
				sed -i -e 's/xataz/'$USER'/g' /etc/init.d/medusa-"$USER"
				sed -i -e 's/MD_USER=/MD_USER='$USER'/g' /etc/init.d/medusa-"$USER"
				systemctl daemon-reload
				/etc/init.d/medusa-"$USER" start && sleep 5 && /etc/init.d/medusa-"$USER" stop
				sleep 1
				sed -i -e 's/web_root = ""/web_root = \/medusa/g' "$MEDUSA"/data/"$USER"/config.ini
				sed -i -e 's/web_port = 8081/web_port = '$PORT'/g' "$MEDUSA"/data/"$USER"/config.ini
				sed -i -e 's/torrent_dir = ""/torrent_dir = \/home\/'$USER'\/watch\//g' "$MEDUSA"/data/"$USER"/config.ini
				sed -i -e 's/web_host = 0.0.0.0/web_host = 127.0.0.1/g' "$MEDUSA"/data/"$USER"/config.ini
				FONCSCRIPT "$USER" medusa
				FONCSERVICE start medusa-"$USER"

				if [ ! -f "$NGINXCONFDRAT"/medusa.conf ]; then
					cp -f "$BONOBOX"/files/medusa/medusa.vhost "$NGINXCONFDRAT"/medusa.conf
				else
					sed -i '$d' "$NGINXCONFDRAT"/medusa.conf
					cat <<- EOF >> "$NGINXCONFDRAT"/medusa.conf
					                if (\$remote_user = "@USER@") {
					                        proxy_pass http://127.0.0.1:@PORT@;
					                        break;
			    		           }
			    		  }
					EOF
				fi

				sed -i "s|@USER@|$USER|g;" "$NGINXCONFDRAT"/medusa.conf
				sed -i "s|@PORT@|$PORT|g;" "$NGINXCONFDRAT"/medusa.conf
				FONCSERVICE restart nginx
			;;

			58)
				cp -R "$FILES"/esm/esm "$NGINXWEB"/esm
				chown -R "$WDATA" "$NGINXWEB"/esm
				cp -f "$FILES"/esm/esm.vhost "$NGINXCONFDRAT"/esm.conf
				FONCSERVICE restart nginx
			;;

			59)
				set "184" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				aptitude install dirmngr

				if [[ $VERSION =~ 7. ]]; then
					apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
					echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee /etc/apt/sources.list.d/mono-official.list
				elif [[ $VERSION =~ 8. ]]; then
					apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
					echo "deb http://download.mono-project.com/repo/debian jessie main" | tee /etc/apt/sources.list.d/mono-official.list
				elif [[ $VERSION =~ 9. ]]; then
					apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
					echo "deb http://download.mono-project.com/repo/debian stretch main" | tee /etc/apt/sources.list.d/mono-official.list
				fi

				aptitude update && aptitude install -y  mono-xsp4


				LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/Jackett/Jackett/releases/latest)
				LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
				wget https://github.com/Jackett/Jackett/releases/download/"$LATEST_VERSION"/Jackett.Binaries.Mono.tar.gz

				tar -xvf Jackett.Binaries.Mono.tar.gz
				mkdir /opt/jackett
				mv Jackett/* /opt/jackett
				chown -R "$USER":"$USER" /opt/jackett
				mkdir /home/"$USER"/.config
				chown -R "$USER":"$USER" /home/"$USER"/.config

				cp -f "$BONOBOX"/files/jackett/jackett /etc/init.d/jackett
				sed -i -e "s/RUN_AS=/RUN_AS=$USER/g" /etc/init.d/jackett
				systemctl daemon-reload
				chmod +x /etc/init.d/jackett
				update-rc.d jackett defaults
				FONCSERVICE start jackett && sleep 1 && FONCSERVICE stop jackett

				sed -i -e 's/"BasePathOverride": null/"BasePathOverride": "\/jackett"/g' /home/"$USER"/.config/Jackett/ServerConfig.json
				service jackett start

				cp -f "$BONOBOX"/files/jackett/jackett.vhost "$NGINXCONFDRAT"/jackett.conf

				FONCSERVICE restart nginx
			;;

			*) # fail
				set "292"; FONCTXT "$1"; echo -e "${CRED}$TXT1${CEND}"
			;;
		esac
	done
fi
