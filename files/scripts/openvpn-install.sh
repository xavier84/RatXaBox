#!/bin/bash
# OpenVPN road warrior installer for Debian.
#Script original https://github.com/Nyr/openvpn-install
#modifié par Xavier

CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

VERSION=$(cat /etc/debian_version)
OS=debian
GROUPNAME=nogroup
RCLOCAL='/etc/rc.local'


if readlink /proc/$$/exe | grep -qs "dash"; then
	echo -e "${CRED}Le script doit etre lancée avec bash et non avec sh${CEND}"
	exit 1
fi

if [[ ! -e /dev/net/tun ]]; then
	echo -e "${CRED}TUN n'est pas valide${CEND}"
	exit 1
fi


if [[ "$VERSION" =~ 7.* ]] || [[ "$VERSION" =~ 8.* ]]; then
	if [ "$(id -u)" -ne 0 ]; then
		echo -e "${CRED}Ce script doit être exécuté en root${CEND}"
		exit 1
	fi
else
		echo -e "${CRED}Ce script doit être exécuté sur Debian 7 ou 8 exclusivement.${CEND}"
		exit 1
fi



newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-common.txt ~/$1.ovpn
	echo "<ca>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/$1.ovpn
	echo "</ca>" >> ~/$1.ovpn
	echo "<cert>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> ~/$1.ovpn
	echo "</cert>" >> ~/$1.ovpn
	echo "<key>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> ~/$1.ovpn
	echo "</key>" >> ~/$1.ovpn
	echo "<tls-auth>" >> ~/$1.ovpn
	cat /etc/openvpn/ta.key >> ~/$1.ovpn
	echo "</tls-auth>" >> ~/$1.ovpn
}

# Try to get our IP from the system and fallback to the Internet.
# I do this to make the script compatible with NATed servers (lowendspirit.com)
# and to avoid getting an IPv6.
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
		IP=$(wget -qO- ipv4.icanhazip.com)
fi

if [[ -e /etc/openvpn/server.conf ]]; then
	while :
	do
	clear
		echo -e "${CGREEN}OpenVPN et déja installer${CEND}"
		echo ""
		echo -e "${CBLUE}Que veux tu faire?${CEND}"
		echo -e "${CBLUE}   1) Ajouté un nouveaux certificat${CEND}"
		echo -e "${CBLUE}   2) Supprimer un certificat${CEND}"
		echo -e "${CBLUE}   3) Désinstaller OpenVPN${CEND}"
		echo -e "${CBLUE}   4) Sortir${CEND}"
		read -p "$(echo -e ${CYELLOW}Choisir une option [1-4]: ${CEND})" option
		case $option in
			1)
			echo ""
			echo -e "${CBLUE}Entrer un nom pour le certificat${CEND}"
			echo -e "${CBLUE}En un seul mot et sans caractères spéciaux${CEND}"
			read -p "$(echo -e ${CYELLOW}Nom du certificat: ${CEND})" -e -i client CLIENT
			cd /etc/openvpn/easy-rsa/
			./easyrsa build-client-full $CLIENT nopass
			# Generates the custom client.ovpn
			newclient "$CLIENT"
			echo ""
			echo -e "${CBLUE}Certificat $CLIENT crée dans le dossier${CEND} ${CRED}~/$CLIENT.ovpn${CEND}"
			exit
			;;
			2)
			# This option could be documented a bit better and maybe even be simplimplified
			# ...but what can I say, I want some sleep too
			NUMBEROFCLIENTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c "^V")
			if [[ "$NUMBEROFCLIENTS" = '0' ]]; then
				echo ""
				echo -e "${CGREEN}Tu n'as pas de certificat!${CEND}"
				exit 6
			fi
			echo ""
			echo -e "${CBLUE}Sélectionne le certificat que tu veux révoquer${CEND}"
			tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '
			if [[ "$NUMBEROFCLIENTS" = '1' ]]; then
				read -p "$(echo -e ${CYELLOW}Select one client [1]: ${CEND})" CLIENTNUMBER
			else
				read -p "$(echo -e ${CYELLOW}Select one client [1-$NUMBEROFCLIENTS]: ${CEND})" CLIENTNUMBER
			fi
			CLIENT=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | sed -n "$CLIENTNUMBER"p)
			cd /etc/openvpn/easy-rsa/
			./easyrsa --batch revoke $CLIENT
			./easyrsa gen-crl
			rm -rf pki/reqs/$CLIENT.req
			rm -rf pki/private/$CLIENT.key
			rm -rf pki/issued/$CLIENT.crt
			rm -rf /etc/openvpn/crl.pem
			cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
			# CRL is read with each client connection, when OpenVPN is dropped to nobody
			chown nobody:$GROUPNAME /etc/openvpn/crl.pem
			echo ""
			echo -e "${CGREEN}Certificat $CLIENT révoqué${CEND}"
			exit
			;;
			3)
			echo ""
			read -p "$(echo -e ${CRED}Veux tu vraiment supprimer OpenVPN?[y/n]: ${CEND})" -e -i n REMOVE
			if [[ "$REMOVE" = 'y' ]]; then
				PORT=$(grep '^port ' /etc/openvpn/server.conf | cut -d " " -f 2)
				if iptables -L -n | grep -qE 'REJECT|DROP'; then
					sed -i "/iptables -I INPUT -p udp --dport $PORT -j ACCEPT/d" $RCLOCAL
					sed -i "/iptables -I FORWARD -s 10.8.0.0\/24 -j ACCEPT/d" $RCLOCAL
					sed -i "/iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT/d" $RCLOCAL
				fi
				sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0\/24 -j SNAT --to /d' $RCLOCAL
				apt-get remove --purge -y openvpn openvpn-blacklist
				rm -rf /etc/openvpn
				rm -rf /usr/share/doc/openvpn*
				echo ""
				echo -e "${CRED}OpenVPN supprimée!${CEND}"
			else
				echo ""
				echo -e "${CRED}Aabandon de la désinstallation!${CEND}"
			fi
			exit
			;;
			4) exit;;
		esac
	done
else
	clear
	echo -e "${CGREEN}
                                      |          |_)         _|
            __ \`__ \   _ \  __ \   _\` |  _ \  _\` | |  _ \   |    __|
            |   |   | (   | |   | (   |  __/ (   | |  __/   __| |
           _|  _|  _|\___/ _|  _|\__,_|\___|\__,_|_|\___|_)_|  _|


         ____    __   ____  _  _    __    ____  _____  _  _
        (  _ \  /__\ (_  _)( \/ )  /__\  (  _ \(  _  )( \/ )
         )   / /(__)\  )(   )  (  /(__)\  ) _ < )(_)(  )  (
        (_)\_)(__)(__)(__) (_/\_)(__)(__)(____/(_____)(_/\_)
		${CEND}"
	echo -e "${CBLUE}Bienvenue sur installation de OpenVPN${CEND}"
	echo ""
	echo -e "${CBLUE}Qu'elle adresse IPv4 veux tu utiliser pour OpenVPN${CEND}"
	echo ""
	read -p "$(echo -e ${CYELLOW}IP addresse: ${CEND})" -e -i $IP IP
	echo ""
	echo -e "${CBLUE}Qu'elle port pour OpenVPN?${CEND}"
	read -p "$(echo -e ${CYELLOW}Port: ${CEND})""Port: " -e -i 1194 PORT
	echo ""
	echo ""
	echo -e "${CBLUE}Entrer un nom pour le certificat${CEND}"
	echo -e "${CBLUE}En un seul mot et sans caractères spéciaux${CEND}"
	read -p "$(echo -e ${CYELLOW}Nom du certificat: ${CEND})" -e -i client CLIENT
	echo ""
	echo -e "${CBLUE}Ok, c'était tout ce dont j'avais besoin. prêts à installer et configurer votre serveur OpenVPN maintenant${CEND}"
	read -n1 -r -p "$(echo -e ${CYELLOW}Appuyez sur n\'importe quelle touche pour continuer ${CEND})"

	apt-get update
	apt-get install openvpn iptables openssl ca-certificates -y

	# An old version of easy-rsa was available by default in some openvpn packages
	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi
	# Get easy-rsa
	wget -O ~/EasyRSA-3.0.1.tgz https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz
	tar xzf ~/EasyRSA-3.0.1.tgz -C ~/
	mv ~/EasyRSA-3.0.1/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.1/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.1.tgz
	cd /etc/openvpn/easy-rsa/
	# Create the PKI, set up the CA, the DH params and the server + client certificates
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $CLIENT nopass
	./easyrsa gen-crl
	# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn
	# CRL is read with each client connection, when OpenVPN is dropped to nobody
	chown nobody:$GROUPNAME /etc/openvpn/crl.pem
	# Generate key for tls-auth
	openvpn --genkey --secret /etc/openvpn/ta.key
	# Generate server.conf
	echo "port $PORT
proto udp
dev tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" > /etc/openvpn/server.conf
echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
done
echo "keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group $GROUPNAME
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem" >> /etc/openvpn/server.conf
	# Enable net.ipv4.ip_forward for the system
	sed -i '/\<net.ipv4.ip_forward\>/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
	if ! grep -q "\<net.ipv4.ip_forward\>" /etc/sysctl.conf; then
		echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
	fi
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
	# Set NAT for the VPN subnet
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
	sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
	iptables -I INPUT -p udp --dport $PORT -j ACCEPT
	iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
	iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
	sed -i "1 a\iptables -I INPUT -p udp --dport $PORT -j ACCEPT" $RCLOCAL
	sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
	sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL


	if pgrep systemd-journal; then
		systemctl restart openvpn@server.service
	else
		/etc/init.d/openvpn restart
	fi

	if pgrep systemd-journal; then
		systemctl restart openvpn@server.service
		systemctl enable openvpn@server.service
	else
		service openvpn restart
		chkconfig openvpn on
	fi

	# Try to detect a NATed connection and ask about it to potential LowEndSpirit users
	EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
	if [[ "$IP" != "$EXTERNALIP" ]]; then
		echo ""
		echo -e "${CGREEN}On dirait que ton serveur est derrière un NAT!${CEND}"
		echo ""
		echo -e "${CBLUE}Si votre serveur est NAT (par exemple une livebox, freebox etc), je dois connaître l'adresse IP externe${CEND}"
		echo -e "${CBLUE}Si ce n'est pas le cas, il suffit d'ignorer et de laisser le champ suivant vide${CEND}"
		read -p "$(echo -e ${CYELLOW}External IP: ${CEND})" -e USEREXTERNALIP
		if [[ "$USEREXTERNALIP" != "" ]]; then
			IP=$USEREXTERNALIP
		fi
	fi
	# client-common.txt is created so we have a template to add further users later
	echo "client
dev tun
proto udp
sndbuf 0
rcvbuf 0
remote $IP $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
comp-lzo
setenv opt block-outside-dns
key-direction 1
verb 3" > /etc/openvpn/client-common.txt
	# Generates the custom client.ovpn
	newclient "$CLIENT"
	echo ""
	echo -e "${CGREEN}Fini!${CEND}"
	echo ""
	echo -e "${CBLUE}Votre certificat est disponible dans${CEND} ${CRED}/root/$CLIENT.ovpn${CEND}"
	echo -e "${CBLUE}Pour crée des nouveaux/supprimée des certificats, il vous suffit d'exécuter ce script une nouvelle fois!${CEND}"
fi
