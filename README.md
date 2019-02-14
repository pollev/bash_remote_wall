# bash_remote_wall
A bash script to simulate the old Unix 'wall' command over ssh

## Usage:

`(echo "message" | remote_wall.sh remote_machine)`
This will assume that the superuser account on the remote machine is named root

`(echo "message" | remote_wall.sh remote_machine root_name)`
This will use the given root_name as name of the superuser account on the remote machine

The above two cases will prompt once for a password of the root user if this is required for the ssh connection.
You can avoid this by configuring ssh to use private keys or known hosts for authentication rather than passwords.

In case you are forced to use ssh passwords, and want to incorporate this functionality into a script without waiting for user input. It is also possible to supply the root password to the command. This requires that 'sshpass' is installed on the local machine. This is not recommended in any case as it will force you to leave your password in plain text in a script or on the command line.

`(echo "message" | remote_wall.sh remote_machine root_name root_pass)`
This will use the given root_name as name of the superuser account on the remote machine and will use sshpass to login without prompting for a password. This will only work if sshpass is installed on the local machine.

## Example Output

Sender:

    user@local_machine$ cowsay "testing 123" | ~/remote_wall.sh network_machine
    Running remote wall command on network_machine with text: 
     _____________
    < testing 123 >
     -------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||
    user@local_machine$
    
Receiver:

    user@network_machine$
    Broadcast message from user@local_machine (Thu Feb 14 19:39:36 2019):
    
     _____________
    < testing 123 >
     -------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||
    user@network_machine$
