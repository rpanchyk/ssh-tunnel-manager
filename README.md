# SSH Tunnel Manager

This project is aimed to instantiate a reliable SSH tunnel.
It can be used to create a link to your private machine (for example, behind the NAT)
through the public machine (server available from the internet).

## Prerequisites

- Private PC on Linux with SSH client installed
- Public server on Linux with SSH server installed

In case of other OS like MacOS, you should check _installation_ step. All other steps are the same.

## Dependencies

The script requires a few dependency packages to be installed and some configuration performed.

### On public server

- Install required packages:
```
sudo apt-get install git openssh-server
```

- Configure SSH server to be able for tunnel instantiating. Add the next lines to `/etc/ssh/sshd_config` file:
```
PermitTunnel yes
GatewayPorts yes
ClientAliveInterval 60
```

- Restart SSH server:
```
sudo service sshd restart
```

- Configure firewall rules:
```
sudo firewall-cmd --zone=public --add-port=<PUBLIC_PORT>/tcp --permanent
sudo firewall-cmd --reload
sudo service firewalld restart
```
where
  - `<PUBLIC_PORT>` - the port of your service will be available on.


### On private machine

- Install required packages:
```
sudo apt-get install git openssh-client
```

- Generate public/private SSH key pair:
```
ssh-keygen -t rsa -b 4096
```
Attention! Leave empty passphrase when prompted.

Lets assume you creates `/home/user1/.ssh/tun-key` key.

- Run SSH agent with the command:
```
eval "$(ssh-agent -s)"
```

- Import new SSH key:
```
ssh-add /home/user1/.ssh/tun-key
```

- Check the key should be listed:
```
ssh-add -l
```

- Copy SSH key to public server:
```
ssh-copy-id -i /home/user1/.ssh/tun-key <SSH_SERVER_USER>@<SSH_SERVER_IP> -p<SSH_SERVER_PORT>
```
where
  - `<SSH_SERVER_USER>` - the user to login on remote SSH server.
  - `<SSH_SERVER_IP>` - SSH server address.
  - `<SSH_SERVER_PORT>` - SSH server port (use `22` by default).


- Now you should be able to SSH login without password:
```
ssh <SSH_SERVER_USER>@<SSH_SERVER_IP> -p<SSH_SERVER_PORT>
```

## Installation (on private machine)

### Manual usage

To use the script manually follow next steps.

- Clone the repository:
```
git clone https://github.com/acidtron/ssh-tunnel.git
```

- Move to the project directory:
```
cd ssh-tunnel
```

- Run the command:
```
./tun_manager.sh "<REMOTE_PORT>" "<LOCAL_PORT>" "<SSH_SERVER_USER>" "<SSH_SERVER_IP>" "<SSH_SERVER_PORT>" "<SSH_KEY_PATH>"
```
where
  - `<REMOTE_PORT>` - the port of your service will be available on.
  - `<LOCAL_PORT>` - the local SSH tunnel port.
  - `<SSH_SERVER_USER>` - the user to login on remote SSH server.
  - `<SSH_SERVER_IP>` - SSH server address.
  - `<SSH_SERVER_PORT>` - SSH server port (use `22` by default)
  - `<SSH_KEY_PATH>` - your generated SSK key.


- To stop the SSH tunnel:
```
./tun_stop.sh "<REMOTE_PORT>" "<LOCAL_PORT>"
```

### Automatic execution
To use the script in automatic mode perform actions described below.
- Clone the repository:
```
sudo git clone https://github.com/acidtron/ssh-tunnel.git /opt/ssh-tunnel
```
- Add entry to the `/etc/crontab` file:
```
*/5 * * * * root /opt/ssh-tunnel/tun_manager.sh "<REMOTE_PORT>" "<LOCAL_PORT>" "<SSH_SERVER_USER>" "<SSH_SERVER_IP>" "<SSH_SERVER_PORT>" "<SSH_KEY_PATH>" >> /var/log/tun_manager.log
```
where
  - `<REMOTE_PORT>` - the port of your service will be available on.
  - `<LOCAL_PORT>` - the local SSH tunnel port.
  - `<SSH_SERVER_USER>` - the user to login on remote SSH server.
  - `<SSH_SERVER_IP>` - SSH server address.
  - `<SSH_SERVER_PORT>` - SSH server port (use `22` by default)
  - `<SSH_KEY_PATH>` - your generated SSK key.

Actually, it's not desired to be a root to execute the script, so change in your own.

- Apply the cron changes:
```
sudo service cron reload
```

## Testing (on private machine)

- Run simple web server with the command (if your've python installed):
```
sudo python -m SimpleHTTPServer <LOCAL_PORT>
```
where
  - `<LOCAL_PORT>` - the port of your service available locally.


- Open browser:
```
http://<PUBLIC_SERVER_IP>:<REMOTE_PORT>
```
where
  - `<PUBLIC_SERVER_IP>` - the address of your public server.
  - `<REMOTE_PORT>` - the port of your service will be available on.


## Contributing
You can change this script according to your modem device. This is just the idea to solve connection drops.

Report bugs, request features, and suggest improvements [on Github](https://github.com/acidtron/ssh-tunnel/issues).

Or better yet, [open a pull request](https://github.com/acidtron/ssh-tunnel/compare) with the changes you'd like to see.
