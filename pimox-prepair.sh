#!/bin/bash
#./pimox-checker.sh | tee pimox-checker-before.log
#./pimox-checker.sh>pimox-checker-before.log


bash ifaces.sh

echo "und was haben wir jetzt??"
echo "___________________________________________________________________"
echo "###################################################################"
echo "gewählter Hostname: $HOSTNAME"
echo "gewählte IP: $RPI_IP"
echo "gewähltes Gateway: $GATEWAY"
echo "###################################################################"
echo "___________________________________________________________________"

