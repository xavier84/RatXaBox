#!/bin/bash
#
# Envoie sur paste.debian.net désactivé le temps de tester...
# cd /tmp
# git clone https://github.com/PixiBixi/Script-Debug-MonDedie
# cd Script-Debug-MonDedie
# chmod a+x Script-Debug-Mondedie.sh & ./Script-Debug-Mondedie.sh
#

CSI="\033["
CEND="${CSI}0m"
CGREEN="${CSI}1;32m"
CRED="${CSI}1;31m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

RAPPORT="/tmp/rapport.txt"
NOYAU=$(uname -r)
DATE=$(date +"%d-%m-%Y à %H:%M")
DOMAIN=$(hostname -d 2> /dev/null)
WANIP=$(dig o-o.myaddr.l.google.com @ns1.google.com txt +short | sed 's/"//g')
NGINX_VERSION=$(2>&1 nginx -v | grep -Eo "[0-9.+]{1,}")
RTORRENT_VERSION=$(rtorrent -h | grep -E -o "[0-9]\.[0-9].[0-9]{1,}")



if [[ $UID != 0 ]]; then
	echo -e "${CRED}Ce script doit être executé en tant que root${CEND}"
	exit
fi

function gen() {
	if [[ -f $RAPPORT ]]; then
		echo -e "${CRED}\nFichier de rapport détecté${CEND}"
		rm $RAPPORT
		echo -e "${CGREEN}Fichier de rapport supprimé${CEND}"
	fi
	touch $RAPPORT
		cat <<-EOF >> $RAPPORT

		### Rapport pour ruTorrent généré le $DATE ###

		Utilisateur ruTorrent => $USERNAME
		Kernel : $NOYAU
		nGinx : $NGINX_VERSION
		rTorrent Version : $RTORRENT_VERSION
		EOF
}

function checkBin() { # $2 => No installation
	if ! [[ $(dpkg -s "$1" | grep Status ) =~ "Status: install ok installed" ]]  &> /dev/null ; then # $1 = Nom du programme
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

function genRapport() {
	echo -e "${CBLUE}\nFichier de rapport terminé${CEND}\n"
	LINK=$(/usr/bin/pastebinit -b http://paste.ubuntu.com $RAPPORT)
	echo -e "Allez sur le topic adéquat et envoyez ce lien:\n${CYELLOW}$LINK${CEND}"
	echo -e "Rapport stocké dans le fichier : ${CYELLOW}$RAPPORT${CEND}"
}

function rapport() {
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

		...................................
		## $NAME                  ##
		...................................
		EOF
	fi
	cat <<-EOF >> $RAPPORT

	##### ----------- File : $1 -----------------------------------------------------------------------------------------------------------------------------

	$FILE
	EOF
}

function remove() {
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

		gen ruTorrent "$USERNAME"
		checkBin pastebinit

		cat <<-EOF >> $RAPPORT
		...................................
		## Utilisateur                  ##
		...................................
		EOF

		if [[ $(grep "$USERNAME:" -c /etc/shadow) != "1" ]]; then
			echo -e "--> Utilisateur inexistant" >> $RAPPORT
			VALID_USER=0
		else
			echo -e "--> Utilisateur $USERNAME existant" >> $RAPPORT
		fi

		cat <<-EOF >> $RAPPORT

		...................................
		## .rtorrent.rc                  ##
		...................................
		EOF
		if [[ $VALID_USER = 0 ]]; then
			echo "--> Fichier introuvable (Utilisateur inexistant)" >> $RAPPORT
		else
			if ! [[ -f "/home/$USERNAME/.rtorrent.rc" ]]; then
				echo "--> Fichier introuvable" >> $RAPPORT
			else
				cat "/home/$USERNAME/.rtorrent.rc" >> $RAPPORT
			fi
		fi

		rapport /var/log/nginx/rutorrent-error.log nGinx.Logs 1
		rapport /etc/nginx/nginx.conf nGinx.Conf 1
		rapport /etc/nginx/sites-enabled/rutorrent.conf ruTorrent.Conf.nGinx 1
		rapport /var/www/rutorrent/conf/config.php ruTorrent.Config.Php 1

		cat <<-EOF >> $RAPPORT

		...................................
		## ruTorrent Conf Perso (config) ##
		...................................
		EOF
		if [[ $VALID_USER = 0 ]]; then
			echo "--> Fichier introuvable (Utilisateur Invalide)" >> $RAPPORT
		else
			if ! [[ -f "/var/www/rutorrent/conf/users/$USERNAME/config.php" ]]; then
				echo "--> Fichier introuvable" >> $RAPPORT
			else
				cat /var/www/rutorrent/conf/users/"$USERNAME"/config.php >> $RAPPORT
			fi
		fi

		cat <<-EOF >> $RAPPORT

		...................................
		## rTorrent Activity             ##
		...................................
		EOF
		if [[ $VALID_USER = 0 ]]; then
			echo -e "--> Utilisateur inexistant" >> $RAPPORT
		else
			echo -e "$(/bin/ps uU "$USERNAME" | grep -e rtorrent)" >> $RAPPORT
		fi

		genRapport
		remove




