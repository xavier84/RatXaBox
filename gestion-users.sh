#!/bin/bash

################################################
# lancement gestion des utilisateurs ruTorrent #
################################################

# Contrôle installation
if [ ! -f "$RUTORRENT"/histo.log ]; then
	echo "" ; set "220" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
	set "222" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}" ; echo ""
	exit 1
fi

# message d'accueil
clear
echo "" ; set "224" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

# mise en garde
echo "" ; set "226" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
set "228" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
set "230" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
echo "" ; set "232" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
read -r VALIDE

if FONCNO "$VALIDE"; then
	echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
	echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
	exit 1
fi

if FONCYES "$VALIDE"; then

	# Boucle ajout/suppression utilisateur
	while :; do

		# menu gestion multi-utilisateurs
		echo "" ; set "234" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
		set "236" "248" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "238" "250" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "240" "252" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "242" "254" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "244" "256" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "246" "296"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "294" "258"; FONCTXT "$1" "$2"; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "816" "860" ; FONCTXT "$1" "$2" ; echo -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "260" ; FONCTXT "$1" ; echo -n -e "${CBLUE}$TXT1 ${CEND}"
		read -r OPTION

		case $OPTION in

			1) # ajout utilisateur
				while :; do # demande nom user
					set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
					FONCUSER
				done

				echo ""
				while :; do # demande mot de passe
					set "112" "114" "116" ; FONCTXT "$1" "$2" "$3" ; echo -e "${CGREEN}$TXT1${CEND}${CYELLOW}$TXT2${CEND}${CGREEN}$TXT3${CEND}"
					FONCPASS
				done

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

				# création du mot de passe pour cet utilisateur
				echo "${USER}:${USERPWD}" | chpasswd

				# anti-bug /home/user déjà existant
				mkdir -p /home/"$USER"
				chown -R "$USER":"$USER" /home/"$USER"

				# variable utilisateur majuscule
				USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

				# récupération ip serveur
				FONCIP

				su "$USER" -c 'mkdir -p ~/watch ~/torrents ~/.session '

				# calcul port
				FONCPORT "$RUTORRENT" 5001

				# configuration munin
				FONCMUNIN "$USER" "$PORT"

				# config .rtorrent.rc
				FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

				# config user rutorrent.conf
				sed -i '$d' "$NGINXENABLE"/rutorrent.conf
				FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

				# logserver user config
				sed -i '$d' "$SCRIPT"/logserver.sh
				echo "sed -i '/@USERMAJ@\ HTTP/d' access.log" >> "$SCRIPT"/logserver.sh
				sed -i "s/@USERMAJ@/$USERMAJ/g;" "$SCRIPT"/logserver.sh
				echo "ccze -h < /tmp/access.log > $RUTORRENT/logserver/access.html" >> "$SCRIPT"/logserver.sh

				# conf script backup .session (rétro-compatibilité)
				if [ -f "$SCRIPT"/backup-session.sh ]; then
					FONCBAKSESSION
				fi

				# config.php
				mkdir "$RUCONFUSER"/"$USER"
				FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

				# plugin.ini
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

				# permission
				chown -R "$WDATA" "$RUTORRENT"
				chown -R "$USER":"$USER" /home/"$USER"
				chown root:"$USER" /home/"$USER"
				chmod 755 /home/"$USER"

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# htpasswd
				FONCHTPASSWD "$USER"

				# seedbox-manager conf user
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
				FONCSCRIPT "$USER" sickrage

				#config nginx sickrage
				sed -i '$d' "$NGINXCONFD"/sickrage.conf
				cat <<- EOF >> "$NGINXCONFD"/sickrage.conf
				                if (\$remote_user = "@USER@") {
				                        proxy_pass http://127.0.0.1:@PORT@;
				                        break;
		    		           }
		    		  }
				EOF
				# pareil verif du \$remote !

				sed -i "s|@USER@|$USER|g;" "$NGINXCONFD"/sickrage.conf
				sed -i "s|@PORT@|$PORT|g;" "$NGINXCONFD"/sickrage.conf
				sleep 1

				# calcul port couchpotato
				FONCPORT "$COUCHPOTATO" 5051

				#compteur
				echo "$PORT" >> "$COUCHPOTATO"/histo.log

				#config couch
				cp -f "$COUCHPOTATO"/init/ubuntu /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CONFIG=\/etc\/default\/couchpotato/#CONFIG=\/etc\/default\/couchpotato/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/# Provides:          couchpotato/# Provides:          '$USER'/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CP_USER:=couchpotato/CP_USER:='$USER'/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CP_DATA:=\/var\/opt\/couchpotato/CP_DATA:=\/opt\/couchpotato\/data\/'$USER'/g' /etc/init.d/couchpotato-"$USER"
				sed -i -e 's/CP_PIDFILE:=\/var\/run\/couchpotato\/couchpotato.pid/CP_PIDFILE:=\/opt\/couchpotato\/data\/'$USER'\/couchpotato.pid/g' /etc/init.d/couchpotato-"$USER"
				chmod +x /etc/init.d/couchpotato-"$USER"
				FONCSCRIPT "$USER" couchpotato
				/etc/init.d/couchpotato-"$USER" start && sleep 5 && /etc/init.d/couchpotato-"$USER" stop
				sleep 1

				#config de user couch
				chmod -Rf 755  "$COUCHPOTATO"/data/
				cp -f "$BONOBOX"/files/couchpotato/settings.conf "$COUCHPOTATO"/data/"$USER"/settings.conf
				sed -i "s|@USER@|$USER|g;" "$COUCHPOTATO"/data/"$USER"/settings.conf
				sed -i "s|@PORT@|$PORT|g;" "$COUCHPOTATO"/data/"$USER"/settings.conf

				#config nginx couchpotato
				sed -i '$d' "$NGINXCONFD"/couchpotato.conf
				cat <<- EOF >> "$NGINXCONFD"/couchpotato.conf
				                if (\$remote_user = "@USER@") {
		    		                    proxy_pass http://127.0.0.1:@PORT@;
		    		                    break;
		        			       }
		    		  }
				EOF
				# \$remote !

				sed -i "s|@USER@|$USER|g;" "$NGINXCONFD"/couchpotato.conf
				sed -i "s|@PORT@|$PORT|g;" "$NGINXCONFD"/couchpotato.conf
				sleep 1

				FONCSERVICE restart nginx
				echo "" ; set "218" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""
				set "182" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
				set "184" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}" ; echo ""
			;;

			2) # suspendre utilisateur
				echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER

				# variable email (rétro compatible)
				TESTMAIL=$(sed -n "1 p" "$RUTORRENT"/histo.log)
				if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
					EMAIL="$TESTMAIL"
				else
					EMAIL=contact@exemple.com
				fi

				#récupération ip serveur
				FONCIP

				# variable utilisateur majuscule
				USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")

				echo "" ; set "262" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

				# crontab (pour retro-compatibilité)
				crontab -l > /tmp/rmuser
				sed -i "s/* \* \* \* \* if ! ( ps -U $USER | grep rtorrent > \/dev\/null ); then \/etc\/init.d\/$USER-rtorrent start; fi > \/dev\/null 2>&1//g;" /tmp/rmuser
				crontab /tmp/rmuser
				rm /tmp/rmuser

				update-rc.d "$USER"-rtorrent remove

				#arret sickrage
				FONCSERVICE stop sickrage-"$USER"
				update-rc.d sickrage-"$USER" remove

				#arret couchpotato
				FONCSERVICE stop couchpotato-"$USER"
				update-rc.d couchpotato-"$USER" remove

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

				# Seedbox-Manager service minimum
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

				echo "" ; set "264" "268" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
			;;

			3) # rétablir utilisateur
				echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
				read -r USER
				echo "" ; set "270" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

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

				# Seedbox-Manager service normal
				rm "$SBMCONFUSER"/"$USER"/config.ini
				mv "$SBMCONFUSER"/"$USER"/config.bak "$SBMCONFUSER"/"$USER"/config.ini
				chown -R "$WDATA" "$SBMCONFUSER"
				rm "$NGINXBASE"/"$USER".html

				#re-active sickrage
				FONCSCRIPT "$USER" sickrage
				FONCSERVICE start sickrage-"$USER"

				#re-active couchpotato
				FONCSCRIPT "$USER" couchpotato
				FONCSERVICE start couchpotato-"$USER"

				echo "" ; set "264" "272" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
			;;

			4) # modification mot de passe utilisateur
				echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				echo ""
				while :; do
					set "274" "114" "116" ; FONCTXT "$1" "$2" "$3" ; echo -e "${CGREEN}$TXT1${CEND}${CYELLOW}$TXT2${CEND}${CGREEN}$TXT3${CEND}"
					FONCPASS
				done
				echo "" ; set "276" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# modification du mot de passe pour cet utilisateur
				echo "${USER}:${USERPWD}" | chpasswd

				# htpasswd
				FONCHTPASSWD "$USER"

				echo "" ; set "278" "280" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				echo
				set "182" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}"
				set "184" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1${CEND}" ; echo ""
			;;

			5) # suppression utilisateur
				echo "" ; set "214" ; FONCTXT "$1" ; echo -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				echo "" ; set "282" "284" ; FONCTXT "$1" "$2" ; echo -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CGREEN}$TXT2 ${CEND}"
				read -r SUPPR

				if FONCNO "$SUPPR"; then
					echo
				else
					set "286" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}" ; echo ""

					# variable utilisateur majuscule
					USERMAJ=$(echo "$USER" | tr "[:lower:]" "[:upper:]")
					echo -e "$USERMAJ"

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

					# stop user
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

					# supression rc.local (pour retro-compatibilité)
					sed -i "/$USER/d" /etc/rc.local

					# suppression conf rutorrent
					rm -R "${RUCONFUSER:?}"/"$USER"
					rm -R "${RUTORRENT:?}"/share/users/"$USER"

					# suppression pass
					sed -i "/^$USER/d" "$NGINXPASS"/rutorrent_passwd
					rm "$NGINXPASS"/rutorrent_passwd_"$USER"

					# suppression nginx
					sed -i '/location \/'"$USERMAJ"'/,/}/d' "$NGINXENABLE"/rutorrent.conf
					FONCSERVICE restart nginx

					# suppression seebbox-manager
					rm -R "${SBMCONFUSER:?}"/"$USER"

					# suppression backup .session (rétro-compatibilité)
					if [ -f "$SCRIPT"/backup-session.sh ]; then
						sed -i "/backup $USER/d" "$SCRIPT"/backup-session.sh
					fi

					#arret et suppression
					FONCSERVICE stop sickrage-"$USER"
					update-rc.d sickrage-"$USER" remove
					rm -f /etc/init.d/sickrage-"$USER"
					rm -Rf "$SICKRAGE"/data/"$USER"

					#arret et suppression
					FONCSERVICE stop couchpotato-"$USER"
					update-rc.d couchpotato-"$USER" remove
					rm -f /etc/init.d/couchpotato-"$USER"
					rm -Rf "$COUCHPOTATO"/data/"$USER"

					# suppression user
					deluser "$USER" --remove-home

					echo "" ; set "264" "288" ; FONCTXT "$1" "$2" ; echo -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				fi
			;;

			6) # debug
				chmod a+x "$FILES"/scripts/check-rtorrent.sh
				bash "$FILES"/scripts/check-rtorrent.sh

			;;
			10) # option
				chmod a+x ./options.sh
				bash ./options.sh

			;;
			7) # sortir gestion utilisateurs
				echo "" ; set "290" ; FONCTXT "$1" ; echo -n -e "${CGREEN}$TXT1 ${CEND}"
				read -r REBOOT

				if FONCNO "$REBOOT"; then
					FONCSERVICE restart nginx &> /dev/null
					echo "" ; set "200" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
					echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
					echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
					exit 1
				fi

				if FONCYES "$REBOOT"; then
					echo "" ; set "210" ; FONCTXT "$1" ; echo -e "${CBLUE}$TXT1${CEND}"
					echo -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}" ; echo ""
					reboot
				fi

				break
			;;

			*) # fail
				set "292" ; FONCTXT "$1" ; echo -e "${CRED}$TXT1${CEND}"
			;;
		esac
	done
fi
