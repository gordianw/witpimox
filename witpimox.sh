#!/bin/bash
#### SET SOME COLOURS ###################################################################################################################
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
GREY=$(tput setaf 8)


#./pimox-checker.sh | tee pimox-checker-before.log
#./pimox-checker.sh>pimox-checker-before.log
echo  "###############################################################"
echo  "################	JETZT GEHTS LOS	################"
echo  "###############################################################"
## _________________________________________________________________________	##
## HOSTNAME 									##
HOSTNAME=$(cat /etc/hostname)							##

## _________________________________________________________________________	##
## IP-ADDRESSE/NETMASK		
## zuerst alle, die mit "e" oder "v" beginnen					##
## z.B. eth0 eth1, vmbr0 vmbr1

IPeNAME=$(ip r | awk '$5 ~ /^[ev]/ { print $5 }')				
IPeNR=$(ip r | awk '$4 ~ /^pro/' | awk '$3 ~ /^[ev]/ { print $9}')		
IPes=$(ip r | awk '$3 ~ /^[ev]/ { print $1 }' | awk '{ print $0}')		
IPeMASK=${IPes##*/}								
IPeGATE=$(ip r | awk '$5 ~ /^[ev]/ { print $3 }')				

## _________________________________________________________________________	##
## IP-ADDRESSE/NETMASK		
## nun alle, die mit "w"
## z.B. wlano wlan1

IPwNAME=$(ip r | awk '$5 ~ /^[w]/ { print $5 }')				
IPwNR=$(ip r | awk '$4 ~ /^pro/' | awk '$3 ~ /^[w]/ { print $9}')		
IPws=$(ip r | awk '$3 ~ /^[w]/ { print $1 }' | awk '{ print $0}')		
IPwMASK=${IPws##*/}								
IPwGATE=$(ip r | awk '$5 ~ /^[w]/ { print $3 }')				

## _________________________________________________________________________	##

echo "####################################################################"
echo "Folgene IP-Addressen gefunden:"
echo "___________________________________"
echo -e "iface: \t$YELLOW $IPeNAME $NORMAL
	\r   IP: \t$YELLOW $IPeNR/$IPeMASK $NORMAL
	\r   Gateway: \t$YELLOW $IPeGATE $NORMAL"
echo "___________________________________"
echo -e "iface: \t$YELLOW $IPwNAME $NORMAL
	\r   IP: \t$YELLOW $IPwNR/$IPwMASK $NORMAL
	\r   Gateway: \t$YELLOW $IPwGATE $NORMAL"
echo "___________________________________"
echo
echo -e "Hostname: \t$YELLOW $HOSTNAME $NORMAL"
echo
echo "___________________________________________________________________"

echo "####################################################################"
echo "Jetzt wird pimox vorbereitet!" read
echo "Hallo"
echo
#echo "aktueller hostname: $GREEN $HOSTNAME $NORMAL"
echo "Drücken Sie Enter ODER geben den neuen Hostnamen ein:"
echo -en "$YELLOW $HOSTNAME $NORMAL\r $GREEN" 
read HOSTNAMEneu 
echo $NORMAL
if [[ "$HOSTNAMEneu" == '' ]]
then
  HOSTNAMEneu=$HOSTNAME
fi
echo

echo "___________________________________________________________________"
#echo "aktuelle IP: $IPeNR/$IPeMASK"
echo "Drücken Sie Enter ODER geben die neue Addresse und Netzwerkmaske ein:"
echo -en "$YELLOW $IPeNR/$IPeMASK $NORMAL\r $GREEN"
read IPneu
echo $NORMAL
if [[ -z "$IPneu" ]]
then 
  IPneu=$IPeNR/$IPeMASK
fi
echo

echo "___________________________________________________________________"
#echo "aktuelles GATE: $IPeGATE"
echo "Drücken Sie Enter ODER geben die neue Gateway-Addresse ein:"
echo -en "$YELLOW $IPeGATE $NORMAL\r $GREEN"
read GATEneu
echo $NORMAL
if [[ -z "$GATEneu" ]]
then
  GATEneu=$IPeGATE
fi
echo



HOSTNAME=$HOSTNAMEneu
NAME=$IPeNAME
RPI_IP=$IPneu
RPI_IP_ONLY=$(echo "$RPI_IP" | cut -d '/' -f 1)
GATEWAY=$GATEneu

export NORMAL
export RED
export GREEN
export YELLOW
export GREY

export HOSTNAME
export NAME
export RPI_IP
export RPI_IP_ONLY
export GATEWAY

export IPeNAME
export IPeNR
export IPeMASK
export IPeGATE

export IPwNAME
export IPwNR
export IPwMASK
export IPwGATE

############################################################################################################################################################
echo "Das folgende soll alles explortiert werden:"

echo "HOSTNAME: $HOSTNAME"
echo "NAME: $NAME"
echo "RPI_IP: $RPI_IP"
echo "RPI_IP_ONLY: $RPI_IP_ONLY"
echo "GATEWAY: $GATEWAY"

echo "IPeNAME: $IPeNAME"
echo "IPeNR: $IPeNR"
echo "IPeMASK: $IPeMASK"
echo "IPeGATE: $IPeGATE"

echo "IPwNAME: $IPwNAME"
echo "IPwNR: $IPwNR"
echo "IPwMASK: $IPwMASK"
echo "IPwGATE: $IPwGATE"



echo "___________________________________________________________________"
echo "###################################################################"
echo "gewählter Hostname: $HOSTNAME"
echo "gewählte IP: $RPI_IP"
echo "gewähltes Gateway: $GATEWAY"
echo "###################################################################"
echo "___________________________________________________________________"
############################################################################################################################################################


./Rpimox-Install.sh

