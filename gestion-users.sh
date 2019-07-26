#!/bin/bash

################################################
# lancement gestion des utilisateurs ruTorrent #
################################################


# contrôle installation
if [ ! -f "$RUTORRENT"/"$HISTOLOG".log ]; then
	"$CMDECHO" ""; set "220"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
	set "222"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
	exit 1
fi

# test si ratxabox 9
if [ ! -f "$RUTORRENT"/ratxabox9.txt ]; then
	"$CMDECHO" ""
	"$CMDECHO" ""; set "866"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"; "$CMDECHO" ""
	"$CMDECHO" ""
	"$CMDECHO" "cd /tmp"
	"$CMDECHO" "rm -rf ratxabox"
	"$CMDECHO" "git clone https://github.com/xavier84/RatXaBox7-8 ratxabox"
	"$CMDECHO" "cd ratxabox"
	"$CMDECHO" "chmod a+x bonobox.sh && ./bonobox.sh"
	"$CMDECHO" ""
	exit 1
fi

# message d'accueil
"$CMDCLEAR"
"$CMDECHO" ""; set "224"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""
# shellcheck source=/dev/null
. "$INCLUDES"/logo.sh

# mise en garde
"$CMDECHO" ""; set "226"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
set "228"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
set "230"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
"$CMDECHO" ""; set "232"; FONCTXT "$1"; "$CMDECHO" -n -e "${CGREEN}$TXT1 ${CEND}"
read -r VALIDE

if FONCNO "$VALIDE"; then
	"$CMDECHO" ""; set "210"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
	"$CMDECHO" -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; "$CMDECHO" ""
	exit 1
fi

if FONCYES "$VALIDE"; then
	# boucle ajout/suppression utilisateur
	while :; do
		# menu gestion multi-utilisateurs
		"$CMDECHO" ""; set "234"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
		"$CMDECHO" ""
		"$CMDECHO" -e "${CMAG}*****Bonobox*****${CEND}"
		set "236" "248"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "238" "250"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "240" "252"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "242" "254"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "244" "256"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "246" "296"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		set "294" "258"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}"
		"$CMDECHO" ""
		"$CMDECHO" -e "${CMAG}*****RatXaBox*****${CEND}"
		set "836" "810" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #plex 50
		set "838" "812" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #emby 51
		set "840" "814" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #openvpn 52
		set "842" "820" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #filebot 53
		set "844" "822" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #SyncThing 54
		set "846" "824" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #sickrage 55
		set "848" "826" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #couchpotato 56
		set "850" "828" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #medusa 57
		set "852" "834" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #esm 58
		set "854" "864" ; FONCTXT "$1" "$2" ; "$CMDECHO" -e "${CYELLOW}$TXT1${CEND} ${CGREEN}$TXT2${CEND}" #jackett 59
		set "260"; FONCTXT "$1"; "$CMDECHO" -n -e "${CBLUE}$TXT1 ${CEND}"
		read -r OPTION

		case $OPTION in
			1) # ajout utilisateur
				FONCUSER # demande nom user
				"$CMDECHO" ""
				FONCPASS # demande mot de passe

				# récupération 5% root sur /home/user si présent
				FONCFSUSER "$USER"

				# variable email (rétro compatible)
				TESTMAIL=$("$CMDSED" -n "1 p" "$RUTORRENT"/"$HISTOLOG".log)
				if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
					EMAIL="$TESTMAIL"
				else
					EMAIL=contact@exemple.com
				fi

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# ajout utilisateur
				"$CMDUSERADD" -M -s /bin/bash "$USER"

				# création mot de passe utilisateur
				"$CMDECHO" "${USER}:${USERPWD}" | "$CMDCHPASSWD"

				# anti-bug /home/user déjà existant
				"$CMDMKDIR" -p /home/"$USER"
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"

				# variable utilisateur majuscule
				USERMAJ=$("$CMDECHO" "$USER" | "$CMDTR" "[:lower:]" "[:upper:]")

				# récupération ip serveur
				FONCIP

				"$CMDSU" "$USER" -c ""$CMDMKDIR" -p ~/watch ~/torrents ~/.session ~/.backup-session"

				# calcul port
				FONCPORT

				# configuration munin
				FONCMUNIN "$USER" "$PORT"

				# configuration .rtorrent.rc
				FONCTORRENTRC "$USER" "$PORT" "$RUTORRENT"

				# configuration user rutorrent.conf
				"$CMDSED" -i '$d' "$NGINXENABLE"/rutorrent.conf
				FONCRTCONF "$USERMAJ"  "$PORT" "$USER"

				# configuration logserver
				"$CMDSED" -i '$d' "$SCRIPT"/logserver.sh
				"$CMDECHO" "\"\$CMDSED\" -i '/@USERMAJ@\ HTTP/d' access.log" >> "$SCRIPT"/logserver.sh
				"$CMDSED" -i "s/@USERMAJ@/$USERMAJ/g;" "$SCRIPT"/logserver.sh
				"$CMDECHO" "\"\$CMDCCZE\" -h < /tmp/access.log > $RUTORRENT/logserver/access.html" >> "$SCRIPT"/logserver.sh

				# configuration script backup .session (rétro-compatibilité)
				if [ -f "$SCRIPT"/backup-session.sh ]; then
					FONCBAKSESSION
				fi

				# config.php
				"$CMDMKDIR" "$RUCONFUSER"/"$USER"
				FONCPHPCONF "$USER" "$PORT" "$USERMAJ"

				# plugins.ini
				"$CMDCP" -f "$FILES"/rutorrent/plugins.ini "$RUCONFUSER"/"$USER"/plugins.ini
				"$CMDCAT" <<- EOF >> "$RUCONFUSER"/"$USER"/plugins.ini
					[linklogs]
					enabled = no
				EOF

				# configuration autodl-irssi
				if [ -f "/etc/irssi.conf" ]; then
					FONCIRSSI "$USER" "$PORT" "$USERPWD"
				fi

				# chroot user supplémentaire
				"$CMDCAT" <<- EOF >> /etc/ssh/sshd_config
					Match User $USER
					ChrootDirectory /home/$USER
				EOF

				FONCSERVICE restart ssh

				# permissions
				"$CMDCHOWN" -R "$WDATA" "$RUTORRENT"
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"
				"$CMDCHOWN" root:"$USER" /home/"$USER"
				"$CMDCHMOD" 755 /home/"$USER"

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# htpasswd
				FONCHTPASSWD "$USER"

				# seedbox-manager configuration user
				cd "$SBMCONFUSER" || exit
				"$CMDMKDIR" "$USER"
				if [ ! -f "$SBM"/sbm_v3 ]; then
					"$CMDCP" -f "$FILES"/sbm_old/config-user.ini "$SBMCONFUSER"/"$USER"/config.ini
				else
					"$CMDCP" -f "$FILES"/sbm/config-user.ini "$SBMCONFUSER"/"$USER"/config.ini
				fi

				"$CMDSED" -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/https:\/\/graph.domaine.fr/..\/graph\/$USER.php/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/RPC1/$USERMAJ/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/contact@mail.com/$EMAIL/g;" "$SBMCONFUSER"/"$USER"/config.ini

				"$CMDCHOWN" -R "$WDATA" "$SBMCONFUSER"

				# configuration page index munin
				FONCGRAPH "$USER"
				FONCSERVICE start "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE start "$USER"-irssi
				fi

				# log users
				"$CMDECHO" "userlog">> "$RUTORRENT"/"$HISTOLOG".log
				"$CMDSED" -i "s/userlog/$USER:$PORT/g;" "$RUTORRENT"/"$HISTOLOG".log
				FONCSERVICE restart nginx
				"$CMDECHO" ""; set "218"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""
				set "182"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"; "$CMDECHO" ""
			;;

			2) # suspendre utilisateur
				"$CMDECHO" ""; set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER

				# variable email (rétro compatible)
				TESTMAIL=$("$CMDSED" -n "1 p" "$RUTORRENT"/"$HISTOLOG".log)
				if [[ "$TESTMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]*$ ]]; then
					EMAIL="$TESTMAIL"
				else
					EMAIL=contact@exemple.com
				fi

				# récupération ip serveur
				FONCIP

				# variable utilisateur majuscule
				USERMAJ=$("$CMDECHO" "$USER" | "$CMDTR" "[:lower:]" "[:upper:]")

				"$CMDECHO" ""; set "262"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""
				"$CMDUPDATERC" "$USER"-rtorrent remove

				# contrôle présence utilitaire
				if [ ! -f "$NGINXBASE"/aide/contact.html ]; then
					cd /tmp || exit
					"$CMDWGET" http://www.bonobox.net/script/contact.tar.gz
					"$CMDTAR" xzfv contact.tar.gz
					"$CMDCP" -f /tmp/contact/contact.html "$NGINXBASE"/aide/contact.html
					"$CMDCP" -f /tmp/contact/style/style.css "$NGINXBASE"/aide/style/style.css
				fi

				# page support
				"$CMDCP" -f "$NGINXBASE"/aide/contact.html "$NGINXBASE"/"$USER".html
				"$CMDSED" -i "s/@USER@/$USER/g;" "$NGINXBASE"/"$USER".html
				"$CMDCHOWN" -R "$WDATA" "$NGINXBASE"/"$USER".html

				# seedbox-manager service minimum
				"$CMDMV" "$SBMCONFUSER"/"$USER"/config.ini "$SBMCONFUSER"/"$USER"/config.bak
				if [ ! -f "$SBM"/sbm_v3 ]; then
					"$CMDCP" -f "$FILES"/sbm_old/config-mini.ini "$SBMCONFUSER"/"$USER"/config.ini
				else
					"$CMDCP" -f "$FILES"/sbm/config-mini.ini "$SBMCONFUSER"/"$USER"/config.ini
				fi

				"$CMDSED" -i "s/\"\/\"/\"\/home\/$USER\"/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/https:\/\/rutorrent.domaine.fr/..\/$USER.html/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/https:\/\/graph.domaine.fr/..\/$USER.html/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/RPC1/$USERMAJ/g;" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDSED" -i "s/contact@mail.com/$EMAIL/g;" "$SBMCONFUSER"/"$USER"/config.ini

				"$CMDCHOWN" -R "$WDATA" "$SBMCONFUSER"

				# stop user
				FONCSERVICE stop "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE stop "$USER"-irssi
				fi
				"$CMDPKILL" -u "$USER"
				"$CMDMV" /home/"$USER"/.rtorrent.rc /home/"$USER"/.rtorrent.rc.bak
				"$CMDUSERMOD" -L "$USER"

				"$CMDECHO" ""; set "264" "268"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
			;;

			3) # rétablir utilisateur
				"$CMDECHO" ""; set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"
				read -r USER
				"$CMDECHO" ""; set "270"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""

				"$CMDMV" /home/"$USER"/.rtorrent.rc.bak /home/"$USER"/.rtorrent.rc
				# remove ancien script pour mise à jour init.d
				"$CMDUPDATERC" "$USER"-rtorrent remove

				# script rtorrent
				FONCSCRIPTRT "$USER"

				# start user
				"$CMDRM" /home/"$USER"/.session/rtorrent.lock >/dev/null 2>&1
				FONCSERVICE start "$USER"-rtorrent
				if [ -f "/etc/irssi.conf" ]; then
					FONCSERVICE start "$USER"-irssi
				fi
				"$CMDUSERMOD" -U "$USER"

				# seedbox-manager service normal
				"$CMDRM" "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDMV" "$SBMCONFUSER"/"$USER"/config.bak "$SBMCONFUSER"/"$USER"/config.ini
				"$CMDCHOWN" -R "$WDATA" "$SBMCONFUSER"
				"$CMDRM" "$NGINXBASE"/"$USER".html

				"$CMDECHO" ""; set "264" "272"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
			;;

			4) # modification mot de passe utilisateur
				"$CMDECHO" ""; set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				"$CMDECHO" ""; FONCPASS

				"$CMDECHO" ""; set "276"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""

				# variable passe nginx
				PASSNGINX=${USERPWD}

				# modification du mot de passe
				"$CMDECHO" "${USER}:${USERPWD}" | "$CMDCHPASSWD"

				# htpasswd
				FONCHTPASSWD "$USER"

				"$CMDECHO" ""; set "278" "280"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				"$CMDECHO"
				set "182"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"
				set "184"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND}"
				set "186"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}${PASSNGINX}${CEND}"
				set "188"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1${CEND}"; "$CMDECHO" ""
			;;

			5) # suppression utilisateur
				"$CMDECHO" ""; set "214"; FONCTXT "$1"; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				"$CMDECHO" ""; set "282" "284"; FONCTXT "$1" "$2"; "$CMDECHO" -n -e "${CGREEN}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CGREEN}$TXT2 ${CEND}"
				read -r SUPPR

				if FONCNO "$SUPPR"; then
					"$CMDECHO"
				else
					set "286"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"; "$CMDECHO" ""

					# variable utilisateur majuscule
					USERMAJ=$("$CMDECHO" "$USER" | "$CMDTR" "[:lower:]" "[:upper:]")

					# suppression conf munin
					"$CMDRM" "$GRAPH"/img/rtom_"$USER"_*
					"$CMDRM" "$GRAPH"/"$USER".php

					"$CMDSED" -i "/rtom_${USER}_peers.graph_width 700/,+8d" /etc/munin/munin.conf
					"$CMDSED" -i "/\[rtom_${USER}_\*\]/,+6d" /etc/munin/plugin-conf.d/munin-node

					"$CMDRM" /etc/munin/plugins/rtom_"$USER"_*
					"$CMDRM" "$MUNIN"/rtom_"$USER"_*
					"$CMDRM" "$MUNINROUTE"/rtom_"$USER"_*

					FONCSERVICE restart munin-node

					# stop utilisateur
					FONCSERVICE stop "$USER"-rtorrent
					if [ -f "/etc/irssi.conf" ]; then
						FONCSERVICE stop "$USER"-irssi
					fi

					# arrêt user
					"$CMDPKILL" -u "$USER"

					# suppression script
					if [ -f "/etc/irssi.conf" ]; then
						"$CMDRM" /etc/init.d/"$USER"-irssi
						"$CMDUPDATERC" "$USER"-irssi remove
					fi
					"$CMDRM" /etc/init.d/"$USER"-rtorrent
					"$CMDUPDATERC" "$USER"-rtorrent remove

					# suppression configuration rutorrent
					"$CMDRM" -R "${RUCONFUSER:?}"/"$USER"
					"$CMDRM" -R "${RUTORRENT:?}"/share/users/"$USER"

					# suppression mot de passe
					"$CMDSED" -i "/^$USER/d" "$NGINXPASS"/rutorrent_passwd
					"$CMDRM" "$NGINXPASS"/rutorrent_passwd_"$USER"

					# suppression nginx
					"$CMDSED" -i '/location \/'"$USERMAJ"'/,/}/d' "$NGINXENABLE"/rutorrent.conf
					FONCSERVICE restart nginx

					# suppression seedbox-manager
					"$CMDRM" -R "${SBMCONFUSER:?}"/"$USER"

					# suppression backup .session (rétro-compatibilité)
					if [ -f "$SCRIPT"/backup-session.sh ]; then
						"$CMDSED" -i "/backup $USER/d" "$SCRIPT"/backup-session.sh
					fi

					# suppression utilisateur
					"$CMDDELUSER" "$USER" --remove-home
					cd "$BONOBOX"
					"$CMDECHO" ""; set "264" "288"; FONCTXT "$1" "$2"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND} ${CYELLOW}$USER${CEND} ${CBLUE}$TXT2${CEND}"
				fi
			;;

			6) # debug
				"$CMDCHMOD" a+x "$FILES"/scripts/check-rtorrent.sh
				"$CMDBASH" "$FILES"/scripts/check-rtorrent.sh
			;;

			7) # sortir gestion utilisateurs
				"$CMDECHO" ""; set "290"; FONCTXT "$1"; "$CMDECHO" -n -e "${CGREEN}$TXT1 ${CEND}"
				read -r REBOOT

				if FONCNO "$REBOOT"; then
					FONCSERVICE restart nginx &> /dev/null
					"$CMDECHO" ""; set "200"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
					"$CMDECHO" ""; set "210"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
					"$CMDECHO" -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; "$CMDECHO" ""
					exit 1
				fi

				if FONCYES "$REBOOT"; then
					"$CMDECHO" ""; set "210"; FONCTXT "$1"; "$CMDECHO" -e "${CBLUE}$TXT1${CEND}"
					"$CMDECHO" -e "${CBLUE}                          Ex_Rat - http://mondedie.fr${CEND}"; "$CMDECHO" ""
					"$CMDSYSTEMCTL" reboot
				fi
				break
			;;

			50)
				"$CMDAPTGET" install apt-transport-https -y
				"$CMDECHO" "deb https://downloads.plex.tv/repo/deb/ public main" > /etc/apt/sources.list.d/plexmediaserver.list
				"$CMDWGET" -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | "$CMDAPTKEY" add -
				# voir en dessous pour utiliser FONCSERVICE avec systemctl à la place de "$CMDSERVICE"
				"$CMDAPTITUDE" update && "$CMDAPTITUDE" install -y plexmediaserver && "$CMDSERVICE" plexmediaserver start
				#ajout icon de plex
				if [ ! -d "$RUPLUGINS"/linkplex ];then
					"$CMDGIT" clone --progress https://github.com/xavier84/linkplex "$RUPLUGINS"/linkplex
					"$CMDCHOWN" -R "$WDATA" "$RUPLUGINS"/linkplex

				fi
			;;

			51)
				if [[ $VERSION = 9.* ]]; then
					"$CMDECHO" 'deb http://download.opensuse.org/repositories/home:/emby/Debian_9.0/ /' > /etc/apt/sources.list.d/emby-server.list
					"$CMDWGET" http://download.opensuse.org/repositories/home:emby/Debian_9.0/Release.key -O Release.key
					"$CMDAPTKEY" add - < Release.key

				elif [[ $VERSION = 10.* ]]; then
					# PAs DE DEPOT APPAREMENT POUR L'INSTANT, FAUDRA QUE TU VOIS CA ! ;)
					# Je te mets un exit en attendant, faudra tester la sortie...
					exit
				fi

				"$CMDAPTITUDE" update
				"$CMDAPTITUDE" install -y  mono-xsp4 emby-server
				#ajout icon de emby
				if [ ! -d "$RUPLUGINS"/linkemby ];then
					"$CMDGIT" clone --progress https://github.com/xavier84/linkemby "$RUPLUGINS"/linkemby
					"$CMDCHOWN" -R "$WDATA" "$RUPLUGINS"/linkemby
					FONCIP
					"$CMDSED" -i "s/@IP@/$IP/g;" "$RUPLUGINS"/linkemby/conf.php
				fi
			;;

			52)
				"$CMDWGET" https://raw.githubusercontent.com/xavier84/Script-xavier/master/openvpn/openvpn-install.sh
				"$CMDCHMOD" +x openvpn-install.sh && ./openvpn-install.sh
			;;

			53)
				"$CMDWGET" https://raw.githubusercontent.com/xavier84/Script-xavier/master/filebot/filebot.sh
				"$CMDCHMOD" +x filebot.sh && ./filebot.sh
			;;

			54)
				set "184" ; FONCTXT "$1" ; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				"$CMDCURL" -s https://syncthing.net/release-key.txt | "$CMDAPTKEY" add -
				"$CMDECHO" "deb http://apt.syncthing.net/ syncthing release" | "$CMDTEE" /etc/apt/sources.list.d/syncthing.list
				"$CMDAPTGET" update
				"$CMDAPTGET" install syncthing

				"$CMDCP" -f "$FILES"/syncthing/syncthing@.service /etc/systemd/system/syncthing@"$USER".service
				"$CMDSYSTEMCTL" daemon-reload
				"$CMDMKDIR" -p /home/"$USER"/.config/syncthing
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"/.config
				"$CMDCHMOD" -R 700 /home/"$USER"/.config
				"$CMDMKDIR" -p /home/"$USER"/Sync
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"/Sync
				#fix bug
				if [ -f /home/"$USER"/.config/syncthing/config.xml ]; then
					"$CMDSYSTEMCTL" stop syncthing@"$USER".service
					"$CMDRM" -f /home/"$USER"/.config/syncthing/config.xml
				fi
				"$CMDSYSTEMCTL" enable syncthing@"$USER".service
				"$CMDSYSTEMCTL" start syncthing@"$USER".service
				"$CMDSLEEP" 5
				"$CMDSED" -i -e 's/127.0.0.1/0.0.0.0/g' /home/"$USER"/.config/syncthing/config.xml
				#sed -i -e '2,20d' /home/"$USER"/.config/syncthing/config.xml
				"$CMDSYSTEMCTL" restart syncthing@"$USER".service
				"$CMDCP" -f "$BONOBOX"/files/syncthing/syncthing.vhost "$NGINXCONFDRAT"/syncthing.conf
				FONCSERVICE restart nginx
			;;

			55)
				set "184" ; FONCTXT "$1" ; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				if [ ! -d "$SICKRAGE" ];then
					"$CMDAPTGET" install -y git-core python python-cheetah python-pip
					"$CMDGIT" clone --progress https://github.com/SickRage/SickRage "$SICKRAGE"
					cd "$SICKRAGE"
					"$CMDPIP" install -r requirements.txt
					"$CMDCHOWN" -R "$USER":"$USER" "$SICKRAGE"
					"$CMDCHMOD" -R 755 "$SICKRAGE"
					#compteur
					PORT=20001
					"$CMDECHO" "$PORT" >> "$SICKRAGE"/"$SICKRAGELOG".log
				fi
				# calcul port sickrage
				FONCPORT "$SICKRAGE" 20001
				#compteur
				"$CMDECHO" "$PORT" >> "$SICKRAGE"/"$SICKRAGELOG".log
				#config
				"$CMDCP" -f "$BONOBOX"/files/sickrage/sickrage.init /etc/init.d/sickrage-"$USER"
				"$CMDCHMOD" +x /etc/init.d/sickrage-"$USER"
				"$CMDSED" -i -e 's/xataz/'$USER'/g' /etc/init.d/sickrage-"$USER"
				"$CMDSED" -i -e 's/SR_USER=/SR_USER='$USER'/g' /etc/init.d/sickrage-"$USER"
				/etc/init.d/sickrage-"$USER" start && "$CMDSLEEP" 5 && /etc/init.d/sickrage-"$USER" stop
				"$CMDSLEEP" 1
				"$CMDSED" -i -e 's/web_root = ""/web_root = \/sickrage/g' "$SICKRAGE"/data/"$USER"/config.ini
				"$CMDSED" -i -e 's/web_port = 8081/web_port = '$PORT'/g' "$SICKRAGE"/data/"$USER"/config.ini
				"$CMDSED" -i -e 's/torrent_dir = ""/torrent_dir = \/home\/'$USER'\/watch\//g' "$SICKRAGE"/data/"$USER"/config.ini
				"$CMDSED" -i -e 's/web_host = 0.0.0.0/web_host = 127.0.0.1/g' "$SICKRAGE"/data/"$USER"/config.ini
				"$CMDSYSTEMCTL" daemon-reload
				FONCSCRIPT "$USER" sickrage
				FONCSERVICE start sickrage-"$USER"

				if [ ! -f "$NGINXCONFDRAT"/sickrage.conf ]; then
					"$CMDCP" -f "$BONOBOX"/files/sickrage/sickrage.vhost "$NGINXCONFDRAT"/sickrage.conf
				else
					"$CMDSED" -i '$d' "$NGINXCONFDRAT"/sickrage.conf
					"$CMDCAT" <<- EOF >> "$NGINXCONFDRAT"/sickrage.conf
					                if (\$remote_user = "@USER@") {
					                        proxy_pass http://127.0.0.1:@PORT@;
					                        break;
			    		           }
			    		  }
					EOF
				fi

				"$CMDSED" -i "s|@USER@|$USER|g;" "$NGINXCONFDRAT"/sickrage.conf
				"$CMDSED" -i "s|@PORT@|$PORT|g;" "$NGINXCONFDRAT"/sickrage.conf
				FONCSERVICE restart nginx

			;;

			56)
				set "184" ; FONCTXT "$1" ; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				if [ ! -d "$COUCHPOTATO" ];then
					"$CMDAPTGET" install -y git-core python python-cheetah
					"$CMDGIT" clone --progress https://github.com/CouchPotato/CouchPotatoServer.git "$COUCHPOTATO"
					"$CMDCHOWN" -R "$USER":"$USER" "$COUCHPOTATO"
					"$CMDCHMOD" -R 755 "$COUCHPOTATO"
					#compteur
					PORT=5051
					"$CMDECHO" "$PORT" >> "$COUCHPOTATO"/"$COUCHPOTATOLOG".log
				fi
				# calcul port sickrage
				FONCPORT "$COUCHPOTATO" 5051
				#compteur
				"$CMDECHO" "$PORT" >> "$COUCHPOTATO"/"$COUCHPOTATOLOG".log
				#config couch
				"$CMDCP" -f "$BONOBOX"/files/couchpotato/ubuntu /etc/init.d/couchpotato-"$USER"
				"$CMDSED" -i -e 's/CONFIG=\/etc\/default\/couchpotato/#CONFIG=\/etc\/default\/couchpotato/g' /etc/init.d/couchpotato-"$USER"
				"$CMDSED" -i -e 's/# Provides:          couchpotato/# Provides:          '$USER'/g' /etc/init.d/couchpotato-"$USER"
				"$CMDSED" -i -e 's/CP_USER:=couchpotato/CP_USER:='$USER'/g' /etc/init.d/couchpotato-"$USER"
				"$CMDSED" -i -e 's/CP_DATA:=\/var\/opt\/couchpotato/CP_DATA:=\/opt\/couchpotato\/data\/'$USER'/g' /etc/init.d/couchpotato-"$USER"
				"$CMDSED" -i -e 's/CP_PIDFILE:=\/var\/run\/couchpotato\/couchpotato.pid/CP_PIDFILE:=\/opt\/couchpotato\/data\/'$USER'\/couchpotato.pid/g' /etc/init.d/couchpotato-"$USER"
				"$CMDCHMOD" +x /etc/init.d/couchpotato-"$USER"
				"$CMDSYSTEMCTL" daemon-reload
				FONCSCRIPT "$USER" couchpotato
				/etc/init.d/couchpotato-"$USER" start && "$CMDSLEEP" 5 && /etc/init.d/couchpotato-"$USER" stop
				"$CMDSLEEP" 1
				#config de user couch
				"$CMDCHMOD" -Rf 755  "$COUCHPOTATO"/data/
				"$CMDCP" -f "$BONOBOX"/files/couchpotato/settings.conf "$COUCHPOTATO"/data/"$USER"/settings.conf
				"$CMDSED" -i "s|@USER@|$USER|g;" "$COUCHPOTATO"/data/"$USER"/settings.conf
				"$CMDSED" -i "s|@PORT@|$PORT|g;" "$COUCHPOTATO"/data/"$USER"/settings.conf
				FONCSCRIPT "$USER" couchpotato
				FONCSERVICE start couchpotato-"$USER"

				if [ ! -f "$NGINXCONFDRAT"/couchpotato.conf ]; then
					"$CMDCP" -f "$BONOBOX"/files/couchpotato/couchpotato.vhost "$NGINXCONFDRAT"/couchpotato.conf
				else
					#config nginx couchpotato
					"$CMDSED" -i '$d' "$NGINXCONFDRAT"/couchpotato.conf
					"$CMDCAT" <<- EOF >> "$NGINXCONFDRAT"/couchpotato.conf
					                if (\$remote_user = "@USER@") {
				                        proxy_pass http://127.0.0.1:@PORT@;
				                        break;
					               }
					      }
					EOF
				fi

				"$CMDSED" -i "s|@USER@|$USER|g;" "$NGINXCONFDRAT"/couchpotato.conf
				"$CMDSED" -i "s|@PORT@|$PORT|g;" "$NGINXCONFDRAT"/couchpotato.conf
				FONCSERVICE restart nginx
			;;

			57)
				set "184" ; FONCTXT "$1" ; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				if [ ! -d "$MEDUSA" ];then
					"$CMDAPTGET" install -y git-core python python-cheetah
					cd /tmp || exit
	                "$CMDGIT" clone --progress https://github.com/pymedusa/Medusa.git "$MEDUSA"
					"$CMDCHOWN" -R "$USER":"$USER" "$MEDUSA"
					"$CMDCHMOD" -R 755 "$MEDUSA"
					#compteur
					PORT=5051
					"$CMDECHO" "$PORT" >> "$MEDUSA"/"$MEDUSALOG".log
				fi
				# calcul port medusa
				FONCPORT "$MEDUSA" 20100
				#compteur
				"$CMDECHO" "$PORT" >> "$MEDUSA"/"$MEDUSALOG".log
				#config
				"$CMDCP" -f "$BONOBOX"/files/medusa/medusa.init /etc/init.d/medusa-"$USER"
				"$CMDCHMOD" +x /etc/init.d/medusa-"$USER"
				"$CMDSED" -i -e 's/xataz/'$USER'/g' /etc/init.d/medusa-"$USER"
				"$CMDSED" -i -e 's/MD_USER=/MD_USER='$USER'/g' /etc/init.d/medusa-"$USER"
				"$CMDSYSTEMCTL" daemon-reload
				/etc/init.d/medusa-"$USER" start && "$CMDSLEEP" 5 && /etc/init.d/medusa-"$USER" stop
				"$CMDSLEEP" 1
				"$CMDSED" -i -e 's/web_root = ""/web_root = \/medusa/g' "$MEDUSA"/data/"$USER"/config.ini
				"$CMDSED" -i -e 's/web_port = 8081/web_port = '$PORT'/g' "$MEDUSA"/data/"$USER"/config.ini
				"$CMDSED" -i -e 's/torrent_dir = ""/torrent_dir = \/home\/'$USER'\/watch\//g' "$MEDUSA"/data/"$USER"/config.ini
				"$CMDSED" -i -e 's/web_host = 0.0.0.0/web_host = 127.0.0.1/g' "$MEDUSA"/data/"$USER"/config.ini
				FONCSCRIPT "$USER" medusa
				FONCSERVICE start medusa-"$USER"

				if [ ! -f "$NGINXCONFDRAT"/medusa.conf ]; then
					"$CMDCP" -f "$BONOBOX"/files/medusa/medusa.vhost "$NGINXCONFDRAT"/medusa.conf
				else
					"$CMDSED" -i '$d' "$NGINXCONFDRAT"/medusa.conf
					"$CMDCAT" <<- EOF >> "$NGINXCONFDRAT"/medusa.conf
					                if (\$remote_user = "@USER@") {
					                        proxy_pass http://127.0.0.1:@PORT@;
					                        break;
			    		           }
			    		  }
					EOF
				fi

				"$CMDSED" -i "s|@USER@|$USER|g;" "$NGINXCONFDRAT"/medusa.conf
				"$CMDSED" -i "s|@PORT@|$PORT|g;" "$NGINXCONFDRAT"/medusa.conf
				FONCSERVICE restart nginx
			;;

			58)
				"$CMDCP" -R "$FILES"/esm/esm "$NGINXWEB"/esm
				"$CMDCHOWN" -R "$WDATA" "$NGINXWEB"/esm
				"$CMDCP" -f "$FILES"/esm/esm.vhost "$NGINXCONFDRAT"/esm.conf
				FONCSERVICE restart nginx
			;;

			59)
				set "184" ; FONCTXT "$1" ; "$CMDECHO" -e "${CGREEN}$TXT1 ${CEND}"
				read -r USER
				"$CMDAPTITUDE" install dirmngr

				# J'ai mis la clé en solo pour les deux depots en dessous, buster est présent mais faudra tester biensur ;)
				"$CMDAPTKEY" adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

				if [[ $VERSION = 9.* ]]; then
					#"$CMDAPTKEY" adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
					"$CMDECHO" "deb http://download.mono-project.com/repo/debian stretch main" | "$CMDTEE" /etc/apt/sources.list.d/mono-official.list

				elif [[ $VERSION = 10.* ]]; then
					#"$CMDAPTKEY" adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
					"$CMDECHO" "deb http://download.mono-project.com/repo/debian buster main" | "$CMDTEE" /etc/apt/sources.list.d/mono-official.list
				fi

				"$CMDAPTITUDE" update && "$CMDAPTITUDE" install -y  mono-xsp4 mono-devel libcurl4-openssl-dev


				LATEST_RELEASE=$("$CMDCURL" -L -s -H 'Accept: application/json' https://github.com/Jackett/Jackett/releases/latest)
				LATEST_VERSION=$("$CMDECHO" $LATEST_RELEASE | "$CMDSED" -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
				"$CMDWGET" https://github.com/Jackett/Jackett/releases/download/"$LATEST_VERSION"/Jackett.Binaries.Mono.tar.gz

				"$CMDTAR" -xvf Jackett.Binaries.Mono.tar.gz
				"$CMDMKDIR" /opt/jackett
				"$CMDMV" Jackett/* /opt/jackett
				"$CMDCHOWN" -R "$USER":"$USER" /opt/jackett
				"$CMDMKDIR" /home/"$USER"/.config
				"$CMDCHOWN" -R "$USER":"$USER" /home/"$USER"/.config

				"$CMDCP" -f "$BONOBOX"/files/jackett/jackett /etc/init.d/jackett
				"$CMDSED" -i -e "s/RUN_AS=/RUN_AS=$USER/g" /etc/init.d/jackett
				"$CMDSYSTEMCTL" daemon-reload
				"$CMDCHMOD" +x /etc/init.d/jackett
				"$CMDUPDATERC" jackett defaults
				FONCSERVICE start jackett && sleep 1 && FONCSERVICE stop jackett

				"$CMDSED" -i -e 's/"BasePathOverride": null/"BasePathOverride": "\/jackett"/g' /home/"$USER"/.config/Jackett/ServerConfig.json
				# voir en dessous pour utiliser FONCSERVICE avec systemctl à la place de "$CMDSERVICE"
				"$$CMDSERVICE" jackett start

				"$CMDCP" -f "$BONOBOX"/files/jackett/jackett.vhost "$NGINXCONFDRAT"/jackett.conf

				FONCSERVICE restart nginx
			;;

			*) # fail
				set "292"; FONCTXT "$1"; "$CMDECHO" -e "${CRED}$TXT1${CEND}"
			;;
		esac
	done
fi
