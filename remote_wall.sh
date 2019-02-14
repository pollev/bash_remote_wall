#!/bin/bash

# WALLTEXT = STDIN (echo "message" | remote_wall.sh)
WALLTEXT=$(cat)

# THESE VARIABLES ARE READ FROM USER INPUT (echo "message" | remote_wall.sh remote_machine user pass)
SERVER_SSH_HOST="$1"
# ... as user root
ROOT_USER="$2"
ROOT_PASSWORD="$3"


##########################################################################################################################
# INSTRUCTIONS                                                                                                           #
#                                                                                                                        #
# This script simulates the 'wall' command on a remote server and works on                                               #
# terminals that do not have a login (most terminals that are part of X these days)                                      #
#                                                                                                                        #
##########################################################################################################################

ROOTPASS="sshpass -p ${ROOT_PASSWORD} ssh -o ForwardX11=no ${ROOT_USER}@${SERVER_SSH_HOST}"

main() {
    echo "Running remote wall command on ${SERVER_SSH_HOST} with text: "
    echo "${WALLTEXT}"

    $ROOTPASS 'ps -ef | grep " pts/" | awk '"'"'{print $6}'"'"' | sort -u | grep "pts" > /tmp/terminals_list.temp'
    $ROOTPASS 'ps -ef | grep " tty" | awk '"'"'{print $6}'"'"' | sort -u | grep -v "pts" | grep "tty" >> /tmp/terminals_list.temp'

    pre="\nBroadcast message from $(whoami)@$(hostname) ($(date +"%a %b %d %H:%M:%S %Y")):\n\n"
    message=$(echo "${WALLTEXT}" | sed -s 's/\\/\\\\/g') # Replace all '\' with '\\'
    post="\n"

    $ROOTPASS "cat /tmp/terminals_list.temp | while read TTY_TO; do echo -e "'"'"${pre}${message}${post}"'"'" | tee /dev/"'$TTY_TO'" 1>/dev/null; done"
    $ROOTPASS 'rm /tmp/terminals_list.temp'
}


main
