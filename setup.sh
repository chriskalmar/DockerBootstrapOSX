#!/bin/bash
# Author: Jón Grétar Borgþórsson
# Site: https://github.com/JonGretar/DockerBootstrapOSX
#
# Based on these things:
# 	* https://github.com/frosenberg/docker-dns-scripts
# 	* https://github.com/kitematic/kitematic
#
function printOK {
	if [ $? == 0 ];
	then
		echo "$(tput setaf 2)[OK]$(tput sgr0)"
	else
		echo "$(tput setaf 1)[FAIL]$(tput sgr0)"
		exit 1
	fi
}

function waitForDockerDaemon {
	status=1
	while [ $status == 1 ]
	do
		docker version > /dev/null 2>&1
		status=$?
		sleep 3
	done
	printOK
}

# Check if we are on OSX
printf "*** Are we running on MacOS X ... "
if [[ $(uname -s) =~ Darwin ]]; then
	printOK
else
	echo "$(tput setaf 1)[FAIL]$(tput sgr0)"
	exit 1
fi

printf "*** Looking for VirtualBox  ... "
# check if VirtualBox is installed
command -v VBoxManage > /dev/null 2>&1 || {
	echo "$(tput setaf 1)[FAIL]$(tput sgr0)"
	echo ""
	echo >&2 "VirtualBox not found."
	echo >&2 "Please install latest version from https://www.virtualbox.org/wiki/Downloads"
	exit 1
}
printOK

printf "*** Looking for Boot2Docker  ... "
# check if boot2docker is installed
command -v boot2docker > /dev/null 2>&1 || {
	echo "$(tput setaf 1)[FAIL]$(tput sgr0)"
	echo ""
	echo >&2 "boot2docker not found."
	echo >&2 "Please install using 'brew install boot2docker'."
	exit 1
}
printOK

printf "*** Looking for Docker  ... "
# check if boot2docker is installed
command -v docker > /dev/null 2>&1 || {
	echo "$(tput setaf 1)[FAIL]$(tput sgr0)"
	echo ""
	echo >&2 "Docker not found."
	echo >&2 "Please install using 'brew install docker'."
	exit 1
}
printOK

# check if boot2docker-vm exists
vm=`VBoxManage list vms | grep boot2docker-vm`
if [ $? == 1 ]; # VM does not exist
then
	printf "*** boot2docker-vm not found. Creating (Takes a few minutes) ..."
	boot2docker init > /dev/null 2>&1 || { echo >&2 "  \nSkipping boot2docker (already ran)"; }
	printOK
else
	printf "*** Found existing boot2docker-vm  ... "
	printOK
fi

printf "*** Booting boot2docker-vm ... "
boot2docker up > /dev/null 2>&1
printOK

printf "*** Finding the host only adapter name ... "
VBOXNET=""
if [[ $(VBoxManage showvminfo boot2docker-vm --machinereadable) =~ hostonlyadapter.=\"([A-Za-z0-9]+)\" ]]; then
	VBOXNET=${BASH_REMATCH[1]}
	printf " ($VBOXNET) "
	printOK
else
	echo >&2 "Unable to read the host only adapter's name"
	exit 1
fi

printf "*** Finding the docker host IP ... "
DOCKERIP=$(boot2docker ip 2>/dev/null)
printf " ($DOCKERIP) "
printOK

echo "Please enter your password to continue"
sudo echo ""

printf "*** Adding IP routes to docker containers ..."
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
  <key>Label</key>
  <string>com.kitematic.route</string>
  <key>ProgramArguments</key>
  <array>
    <string>bash</string>
    <string>-c</string>
    <string>/usr/sbin/scutil -w State:/Network/Interface/$VBOXNET/IPv4 -t 0;sudo /sbin/route -n add -net 172.17.0.0 -netmask 255.255.0.0 -gateway $DOCKERIP</string>
  </array>
  <key>KeepAlive</key>
  <false/>
  <key>RunAtLoad</key>
  <true/>
  <key>LaunchOnlyOnce</key>
  <true/>
</dict>
</plist>" | sudo tee /Library/LaunchDaemons/io.boot2docker.route.plist >/dev/null
sudo /sbin/route delete -net 172.17.0.0 -netmask 255.255.0.0 -gateway $DOCKERIP > /dev/null || true
sudo /sbin/route -n add -net 172.17.0.0 -netmask 255.255.0.0 -gateway $DOCKERIP > /dev/null
printOK

printf "*** Configuring Docker for setup ..."
export DOCKER_HOST=tcp://$DOCKERIP:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=$HOME/.boot2docker/certs/boot2docker-vm
printOK

printf "*** Setting Boot2Docker VM as the DNS server for *.docker ..."
sudo mkdir -p /etc/resolver
echo "nameserver $DOCKERIP" | sudo tee /etc/resolver/docker >/dev/null
printOK

echo "*** Creating the dns container (This will take a while) ..."
docker run --name dns -d -p 53:53 -p 53:53/udp --restart=always \
	-v /var/run/docker.sock:/docker.sock phensley/docker-dns \
	--domain docker --record boot2docker:$(boot2docker ip)  || true
echo $?
printOK

echo "*** Creating the log container (This will take a while) ..."
docker run --name log -d -e "PORT=80" --restart=always \
	-v=/var/run/docker.sock:/tmp/docker.sock progrium/logspout  || true
printOK

echo "*** Creating the ui container (This will take a while) ..."
docker run --name ui -d -v /var/run/docker.sock:/docker.sock --restart=always \
  crosbymichael/dockerui -p :80 -e /docker.sock  || true
printOK

echo "*** Installing nsenter ..."
boot2docker ssh 'docker run --rm -v /var/lib/boot2docker:/target jpetazzo/nsenter'
printOK


printf "*** Finished ... "
printOK

echo """
********************************************************************************

The Boot2Docker virtual machine is now up. It's address is boot2docker.docker.
You can shut it down and start it with $(tput setaf 3)boot2docker down$(tput sgr0) and $(tput setaf 3)boot2docker up$(tput sgr0).
It is not set up to start automatically on Mac workstation bootup.

Image phensley/docker-dns is installed under container 'dns'. It will autmatically
add dns for containers as CONTAINER_NAME.docker.

Image progrium/logspout is installed under container 'log'. To see logs from all
containers try $(tput setaf 3)curl http://log.docker/logs$(tput sgr0).
For more info visit https://github.com/progrium/logspout

Image crosbymichael/dockerui installed under container 'ui'. To see docker info
visit http://ui.docker/.

The containers might not run on Boot2Docker startup. Start them with:

	$(tput setaf 3)docker start dns ui log$(tput sgr0)

To see all containers and their running state type:

	$(tput setaf 3)docker ps -a$(tput sgr0)


Please add the following do your .bash_profile file for the 'docker' cli tool.
$(tput setaf 5)
	export DOCKER_HOST=tcp://$DOCKERIP:2376
	export DOCKER_TLS_VERIFY=1
	export DOCKER_CERT_PATH=$HOME/.boot2docker/certs/boot2docker-vm
$(tput sgr0)
"""
