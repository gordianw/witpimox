# !/bin/bash
#######################################################################
# Name:     RPiOS64-IA-Install.sh           Version:      0.1.2       #
# Created:  07.09.2021                      Modified: 22.02.2022      #
# Author:   TuxfeatMac J.T.                                           #
# Purpose:  interactive, automatic, Pimox7 installation RPi4B, RPi3B+ #
echo "#########################################################################################################################################
# Tested with image															#
# from:																        #
# ${BLUE} https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-11-08/2021-10-30-raspios-bullseye-arm64-lite.zip ${NORMAL}#
#########################################################################################################################################"


#### SCRIPT IS MENT TO BE TO RUN AS ROOT! NOT AS PI WITH SUDO ###########################################################################
if [ $USER != root ]
 then
  printf "${RED}PLEASE RUN THIS SCRIPT AS ROOT! DONT USE SUDO! $NORMAL \n"
  exit
fi
printf " $YELLOW
====================================================================
!    PLEASE DONT USE SUDO, USE SU TO LOGIN TO THE ROOT USER        !
! PLEASE STOP THIS SCRIPT NOW WITH CONTROL+C IF YOU ARE USING SUDO !
!               CONTINUING SETUP IN 1 SECONDS...                   !
====================================================================
$NORMAL\n" && sleep 1




#### AGREE TO CHANGES ###################################################################################################################
printf "
$YELLOW#########################################################################################
=========================================================================================$NORMAL
THE NEW HOSTNAME WILL BE:$GREEN $HOSTNAME $NORMAL
=========================================================================================
THE DHCP SERVER ($YELLOW dhcpcd5 $NORMAL) WILL BE $RED REMOVED $NORMAL !!!
=========================================================================================
THE PIMOX REPO WILL BE ADDED IN : $YELLOW /etc/apt/sources.list.d/pimox.list $NORMAL CONFIGURATION :
$GRAY# Pimox 7 Development Repo$NORMAL
deb https://raw.githubusercontent.com/pimox/pimox7/master/ dev/
=========================================================================================
THE NETWORK CONFIGURATION IN : $YELLOW /etc/network/interfaces $NORMAL WILL BE $RED CHANGED $NORMAL !!! TO :
auto lo
iface lo inet loopback
iface $GREEN $NAME $NORMAL inet manual
auto vmbr0
iface vmbr0 inet static
        address $GREEN $RPI_IP $NORMAL
        gateway $GREEN $GATEWAY $NORMAL
        bridge-ports $GREEN $NAME $NORMAL
        bridge-stp off
        bridge-fd 0
=========================================================================================
THE HOSTNAMES IN : $YELLOW /etc/hosts $NORMAL WILL BE $RED OVERWRITTEN $NORMAL !!! WITH :
127.0.0.1\tlocalhost
$GREEN $RPI_IP_ONLY $NORMAL: \t$GREEN $HOSTNAME $NORMAL
=========================================================================================
THESE STATEMENTS WILL BE $RED ADDED $NORMAL TO THE $YELLOW /boot/cmdline.txt $NORMAL IF NONE EXISTENT :
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1
$YELLOW=========================================================================================
#########################################################################################\n $NORMAL
"

#### PROMPT FOR CONFORMATION ############################################################################################################
read -p "YOU ARE OKAY WITH THESE CHANGES ? YOUR DECLARATIONS ARE CORRECT ? CONTINUE ? y / n : " CONFIRM
if [ "$CONFIRM" != "y" ]; then exit; fi

#### SET A ROOT PWD FOR WEB GUI LOGIN ###################################################################################################
#printf "
#=========================================================================================
#                          $RED ! SETUP NEW ROOT PASSWORD ! $NORMAL
#=========================================================================================\n
#" && passwd
#if [ $? != 0 ]; then exit; fi

#### BASE UPDATE, DEPENDENCIES INSTALLATION #############################################################################################
printf "
=========================================================================================
 Begin installation, Normal duration on a default RPi4 ~ 30 minutes, be patient...
=========================================================================================\n
"

#### SET NEW HOSTNAME ###################################################################################################################
hostnamectl set-hostname $HOSTNAME

#### ADD SOURCE PIMOX7 + KEY & UPDATE & INSTALL RPI-KERNEL-HEADERS #######################################################################
printf "# PiMox7 Development Repo
deb https://raw.githubusercontent.com/pimox/pimox7/master/ dev/ \n" > /etc/apt/sources.list.d/pimox.list
curl https://raw.githubusercontent.com/pimox/pimox7/master/KEY.gpg |  apt-key add -
apt update && apt upgrade -y && apt install -y raspberrypi-kernel-headers

#### REMOVE DHCP, CLEAN UP ###############################################################################################################
apt purge -y dhcpcd5
apt autoremove -y

#### FIX CONTAINER STATS NOT SHOWING UP IN WEB GUI #######################################################################################
if [ "$(cat /boot/cmdline.txt | grep cgroup)" != "" ]
 then
  printf "Seems to be already fixed!"
 else
  sed -i "1 s|$| cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1|" /boot/cmdline.txt
fi

#### INSTALL PIMOX7 AND REBOOT ###########################################################################################################
DEBIAN_FRONTEND=noninteractive apt install -y -o Dpkg::Options::="--force-confdef" proxmox-ve

#### RECONFIGURE NETWORK #### /etc/hosts REMOVE IPv6 #### /etc/network/interfaces.new CONFIGURE NETWORK TO CHANGE ON REBOOT ##############
printf "
=========================================================================================
$GREEN ! FIXING NETWORK CONFIGURATION.... ERRORS ARE NOMALAY FINE AND RESOLVED AFTER REBOOT ! $NORMAL
=========================================================================================
\n"
printf "127.0.0.1\tlocalhost
$RPI_IP_ONLY\t$HOSTNAME\n" > /etc/hosts
printf "auto lo
iface lo inet loopback

iface $NAME inet manual

auto vmbr0
iface vmbr0 inet static
        address $RPI_IP
        gateway $GATEWAY
        bridge-ports $NAME
        bridge-stp off
        bridge-fd 0 \n
        
iface $IPwNAME inet manual" > /etc/network/interfaces.new

echo "letzte Chance abzubrechen - ansonsten wird pimox jetzt installiert, Diggersen!"

#### CONFIGURE PIMOX7 BANNER #############################################################################################################
cp /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.auto.backup
SEARCH="return Ext.String.format('"
#### PLACE HOLDER BANNER BEGIN --> #### LINE 1 ####                                                     #### LINEBREAK #### -- #### LINE 2 #####
#REPLACE="return Ext.String.format(' This is a unofficial development build of PVE7 - PIMOX7 - https://github.com/pimox/pimox7  Build to run a PVE7 on the RPi4. ! ! ! NO GUARANTEE NOT OFFICIALLY SUPPORTED ! ! ! ');"
REPLACE="return Ext.String.format(' Josen Digger, PVE7 - PIMOX7 - https://github.com/pimox/pimox7  -  NOT OFFICIALLY SUPPORTED (blablablah)! ');"
sed -i "s|$SEARCH.*|$REPLACE|" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

### FINAL MESSAGE ########################################################################################################################
printf "
=========================================================================================
                   $GREEN     ! INSTALATION COMPLETED ! WAIT ! REBOOT ! $NORMAL
=========================================================================================

    after reboot the PVE web interface will be reachable here :
      --->  $GREEN https://$RPI_IP_ONLY:8006/ $NORMAL <---
      
         run ---> $YELLOW apt upgrade -y $NORMAL <---
           in a root shell to complete the installation.
           
\n" && sleep 10 && reboot

#### EOF ####
