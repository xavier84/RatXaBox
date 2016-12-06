#!/bin/bash
#
# Script original développé par BarracudaXT (BXT)
# https://github.com/PixiBixi/Script-Debug-MonDedie
# Modifié par ex_rat


CSI="\033["
CEND="${CSI}0m"
CGREEN="${CSI}1;32m"
CRED="${CSI}1;31m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

RAPPORT="/tmp/rapport.txt"
DEBIAN_VERSION=$(cat /etc/debian_version)
NOYAU=$(uname -r)
DATE=$(date +"%d-%m-%Y à %H:%M")
NGINX_VERSION=$(2>&1 nginx -v | grep -Eo "[0-9.+]{1,}")
RTORRENT_VERSION=$(rtorrent -h | grep -E -o "[0-9]\.[0-9].[0-9]{1,}")
PHP_VERSION=$(php -v | cut -c 1-7 | grep PHP | cut -c 5-7)

RUTORRENT="/var/www/rutorrent"
RUTORRENT_CONFFILE="/etc/nginx/sites-enabled"


if [[ $UID != 0 ]]; then
	echo -e "${CRED}Ce script doit être executé en tant que root${CEND}"
	exit
fi

FONCGEN () {
	if [[ -f $RAPPORT ]]; then
		echo -e "${CRED}\nFichier de rapport détecté${CEND}"
		rm $RAPPORT
		echo -e "${CGREEN}Fichier de rapport supprimé${CEND}"
	fi
	touch $RAPPORT

	cat <<-EOF >> $RAPPORT

		### Rapport pour ruTorrent généré le $DATE ###

		Utilisateur ruTorrent --> $USERNAME
		Debian : $DEBIAN_VERSION
		Kernel : $NOYAU
		nGinx : $NGINX_VERSION
		rTorrent : $RTORRENT_VERSION
		PHP : $PHP_VERSION
	EOF

	echo "" >> $RAPPORT
	if [[ $(grep "$USERNAME:" -c /etc/shadow) != "1" ]]; then
		echo -e "--> Utilisateur inexistant" >> $RAPPORT
		VALID_USER=0
	else
		echo -e "--> Utilisateur $USERNAME existant" >> $RAPPORT
	fi
}

FONCCHECKBIN () { # $2 => No installation
	if ! [[ $(dpkg -s "$1" | grep Status ) =~ "Status: install ok installed" ]] &> /dev/null ; then # $1 = Nom du programme
		if [[ $2 = 1 ]]; then
			echo "Le programme $1 n'est pas installé" >> $RAPPORT
		else
			echo -e "${CGREEN}\nLe programme${CEND} ${CYELLOW}$1${CEND}${CGREEN} n'est pas installé\nIl va être installé pour la suite du script${CEND}"
			sleep 2
			apt-get -y install "$1" &>/dev/null
		fi
	else
		if [[ $2 = 1 ]]; then
			echo "Le programme $1 est installé" >> $RAPPORT
		fi
	fi
}

FONCGENRAPPORT () {
	echo -e "${CBLUE}\nFichier de rapport terminé${CEND}\n"
	LINK=$(/usr/bin/pastebinit -b http://paste.ubuntu.com $RAPPORT)
	echo -e "Allez sur le topic adéquat et envoyez ce lien:\n${CYELLOW}$LINK${CEND}"
	echo -e "Rapport stocké dans le fichier : ${CYELLOW}$RAPPORT${CEND}"
}

FONCRAPPORT () {
	# $1 = Fichier
	if ! [[ -z $1 ]]; then
		if [[ -f $1 ]]; then
			if [[ $(wc -l < "$1") == 0 ]]; then
				FILE="--> Fichier Vide"
			else
				FILE=$(cat "$1")
			fi
		else
			FILE="--> Fichier Invalide"
		fi
	else
		FILE="--> Fichier Invalide"
	fi

	# $2 = Nom à afficher
	if [[ -z $2 ]]; then
		NAME="Aucun nom donné"
	else
		NAME=$2
	fi

	# $3 = Affichage header
	if [[ $3 == 1 ]]; then
		cat <<-EOF >> $RAPPORT

			......................................................................
			## $NAME
			## File : $1
			......................................................................
		EOF

		cat <<-EOF >> $RAPPORT

			$FILE
		EOF
	fi
}

FONCTESTRTORRENT () {
	SCGI="$(sed -n '/^scgi_port/p' /home/"$USERNAME"/.rtorrent.rc | cut -b 23-)"
	PORT_LISTENING=$(netstat -aultnp | awk '{print $4}' | grep -E ":$SCGI\$" -c)
	RTORRENT_LISTENING=$(netstat -aultnp | sed -n '/'$SCGI'/p' | grep rtorrent -c)

	cat <<-EOF >> $RAPPORT

		......................................................................
		## Test rTorrent & sgci
		......................................................................

	EOF

	# rTorrent lancé
	if [[ "$(ps uU "$USERNAME" | grep -e 'rtorrent' -c)" == [0-1] ]]; then
		echo -e "rTorrent down" >> $RAPPORT
	else
		echo -e "rTorrent Up" >> $RAPPORT
	fi

	# socket
	if (( PORT_LISTENING >= 1 )); then
		echo -e "Un socket écoute sur le port $SCGI" >> $RAPPORT
		if (( RTORRENT_LISTENING >= 1 )); then
			echo -e "C'est bien rTorrent qui écoute sur le port $SCGI" >> $RAPPORT
		else
			echo -e "Ce n'est pas rTorrent qui écoute sur le port $SCGI" >> $RAPPORT
		fi
	else
		echo -e "Aucun programme n'écoute sur le port $SCGI" >> $RAPPORT
	fi

	# ruTorrent
	if [[ -f $RUTORRENT/conf/users/$USERNAME/config.php ]]; then
		if [[ $(cat "$RUTORRENT"/conf/users/"$USERNAME"/config.php) =~ "\$scgi_port = $SCGI" ]]; then
			echo -e "Bon port SCGI renseigné dans le fichier config.php" >> $RAPPORT
		else
			echo -e "Mauvais port SCGI renseigné dans le fichier config.php" >> $RAPPORT
		fi
	else
		echo -e "Répertoire utilisateur trouvé, mais fichier config.php inexistant" >> $RAPPORT
	fi

	# nginx
	if [[ $(cat $RUTORRENT_CONFFILE/rutorrent.conf) =~ $SCGI ]]; then
		echo -e "Les ports nginx et celui indiqué correspondent" >> $RAPPORT
	else
		echo -e "Les ports nginx et celui indiqué ne correspondent pas" >> $RAPPORT
	fi
}

FONCREMOVE () {
	echo -e -n "${CGREEN}\nVoulez vous désinstaller Pastebinit? (y/n):${CEND} "
	read -r PASTEBINIT
	if [[ ${PASTEBINIT^^} == "Y" ]]; then
		apt-get remove -y pastebinit &>/dev/null
		echo -e "${CBLUE}Pastebinit a bien été désinstallé${CEND}"
	else
		echo -e "${CBLUE}Pastebinit n'a pas été désinstallé${CEND}"
	fi
}

# logo
echo -e "${CBLUE}
                                      |          |_)         _|
            __ \`__ \   _ \  __ \   _\` |  _ \  _\` | |  _ \   |    __|
            |   |   | (   | |   | (   |  __/ (   | |  __/   __| |
           _|  _|  _|\___/ _|  _|\__,_|\___|\__,_|_|\___|_)_|  _|


         ____    __   ____  _  _    __    ____  _____  _  _
        (  _ \  /__\ (_  _)( \/ )  /__\  (  _ \(  _  )( \/ )
         )   / /(__)\  )(   )  (  /(__)\  ) _ < )(_)(  )  (
        (_)\_)(__)(__)(__) (_/\_)(__)(__)(____/(_____)(_/\_)
${CEND}"


echo -e -n "${CGREEN}Rentrez le nom de votre utilisateur rTorrent:${CEND} "
read -r USERNAME
echo -e "${CBLUE}Merci de patienter quelques secondes...${CEND}"

FONCGEN ruTorrent "$USERNAME"
FONCCHECKBIN pastebinit

FONCTESTRTORRENT

cat <<-EOF >> $RAPPORT

	......................................................................
	## rTorrent Activity
	......................................................................

EOF

if [[ $VALID_USER = 0 ]]; then
	echo -e "--> Utilisateur inexistant" >> $RAPPORT
else
	echo -e "$(/bin/ps uU "$USERNAME" | grep -e rtorrent)" >> $RAPPORT
fi

cat <<-EOF >> $RAPPORT

	......................................................................
	## Irssi Activity
	......................................................................

EOF

if ! [[ -f "/etc/irssi.conf" ]]; then
	echo -e "--> Irssi non installé" >> $RAPPORT
else
	echo -e "$(/bin/ps uU "$USERNAME" | grep -e irssi)" >> $RAPPORT
fi

cat <<-EOF >> $RAPPORT

	......................................................................
	## .rtorrent.rc
	## File : /home/$USERNAME/.rtorrent.rc
	......................................................................
EOF
echo "" >> $RAPPORT

if [[ $VALID_USER = 0 ]]; then
	echo "--> Fichier introuvable (Utilisateur inexistant)" >> $RAPPORT
else
	if ! [[ -f "/home/$USERNAME/.rtorrent.rc" ]]; then
		echo "--> Fichier introuvable" >> $RAPPORT
	else
		cat "/home/$USERNAME/.rtorrent.rc" >> $RAPPORT
	fi
fi

cat <<-EOF >> $RAPPORT

	......................................................................
	## ruTorrent config.php $USERNAME
	## File : $RUTORRENT/conf/users/$USERNAME/config.php
	......................................................................
EOF
echo "" >> $RAPPORT

if [[ $VALID_USER = 0 ]]; then
	echo "--> Fichier introuvable (Utilisateur Inexistant)" >> $RAPPORT
else
	if [[ ! -f "$RUTORRENT/conf/users/$USERNAME/config.php" ]]; then
		echo "--> Fichier introuvable" >> $RAPPORT
	else
		cat $RUTORRENT/conf/users/"$USERNAME"/config.php >> $RAPPORT
	fi
fi

FONCRAPPORT /etc/init.d/"$USERNAME"-rtorrent "$USERNAME"-rtorrent 1

cd $RUTORRENT_CONFFILE || exit
for VHOST in $(ls)
do
	FONCRAPPORT "$RUTORRENT_CONFFILE"/"$VHOST" "$VHOST" 1
done

if [[ -f $RUTORRENT_CONFFILE/cakebox.conf ]]; then
	FONCRAPPORT /var/www/cakebox/config/"$USERNAME".php cakebox.config.php 1
fi

FONCRAPPORT /etc/nginx/nginx.conf nginx.conf 1

cd /etc/nginx/conf.d || exit
for CONF_D in $(ls)
do
	FONCRAPPORT /etc/nginx/conf.d/"$CONF_D" "$CONF_D" 1
done

cat <<-EOF >> $RAPPORT

	......................................................................
	## fichier pass nginx
	## Dir : /etc/nginx/passwd
	......................................................................
EOF
echo "" >> $RAPPORT

cd /etc/nginx/passwd || exit
for PASS in $(ls)
do
echo "$PASS" >> $RAPPORT
done

cat <<-EOF >> $RAPPORT

	......................................................................
	## fichier ssl nginx
	## Dir : /etc/nginx/ssl
	......................................................................
EOF
echo "" >> $RAPPORT

cd /etc/nginx/ssl || exit
for SSL in $(ls)
do
	echo "$SSL" >> $RAPPORT
done

FONCRAPPORT /var/log/nginx/rutorrent-error.log nginx.log 1

cat <<-EOF >> $RAPPORT

	......................................................................
	## fin
	......................................................................
EOF

FONCGENRAPPORT
FONCREMOVE
