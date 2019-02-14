#!/bin/bash

# WALLTEXT = STDIN (echo "message" | remote_wall.sh)
WALLTEXT=$(cat)

# THESE VARIABLES ARE READ FROM USER INPUT (echo "message" | remote_wall.sh remote_machine user_name user_pass)
SERVER_SSH_HOST="$1"
ROOT_USER="$2"
ROOT_PASS="$3"

# If no username given we assume that the super user is named root
if [ -z "$ROOT_USER" ]
then
      ROOT_USER="root"
fi


##########################################################################################################################
# INSTRUCTIONS                                                                                                           #
#                                                                                                                        #
# This script simulates the 'wall' command on a remote server and works on                                               #
# terminals that do not have a login (most terminals that are part of X these days)                                      #
#                                                                                                                        #
##########################################################################################################################

REMOTE_COMMAND_EXEC=""

select_remote_exec_command() {
    # If the remote user password was provided, we use sshpass to bypass the password prompt

    if [ -z "$ROOT_PASS" ]
    then
        REMOTE_COMMAND_EXEC="ssh -o ForwardX11=no ${ROOT_USER}@${SERVER_SSH_HOST}"
    else
        if command -v sshpass >/dev/null 2>&1; then
            REMOTE_COMMAND_EXEC="sshpass -p ${ROOT_PASS} ssh -o ForwardX11=no ${ROOT_USER}@${SERVER_SSH_HOST}"
        else
            echo "Warning: SSHPASS is not installed on this machine. Ignoring given user password"
            REMOTE_COMMAND_EXEC="ssh -o ForwardX11=no ${ROOT_USER}@${SERVER_SSH_HOST}"
        fi
    fi
}

main() {
    echo "Running remote wall command on ${SERVER_SSH_HOST} with text: "
    echo "${WALLTEXT}"

    pre="\nBroadcast message from $(whoami)@$(hostname) ($(date +"%a %b %d %H:%M:%S %Y")):\n\n"
    message=$(echo "${WALLTEXT}" | sed -s 's/\\/\\\\/g') # Replace all '\' with '\\'
    post="\n"

    select_remote_exec_command;

    $REMOTE_COMMAND_EXEC \
    'ps -ef | grep " pts/" | awk '"'"'{print $6}'"'"' | sort -u | grep "pts" > /tmp/terminals_list.temp;'\
    'ps -ef | grep " tty" | awk '"'"'{print $6}'"'"' | sort -u | grep -v "pts" | grep "tty" >> /tmp/terminals_list.temp;'\
    'cat /tmp/terminals_list.temp | while read TTY_TO; do echo -e "'"${pre}${message}${post}"'" | tee /dev/$TTY_TO 1>/dev/null; done;'\
    'rm /tmp/terminals_list.temp;'
}

main
