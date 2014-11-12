# DockerBootstrapOSX

DockerBootstrapOSX is a little bootstrapping that automates the installation of a Docker environment on a MacOS X machine.

## Quick Install

Make sure you have the latest version of [VirtualBox](http://virtualbox.org/wiki/Downloads), Docker and Boot2Docker installed.

I personally install using [Homebrew](http://brew.sh) with `brew install docker boot2docker`.

Then run the following commands:

	curl -s https://raw.githubusercontent.com/JonGretar/DockerBootstrapOSX/master/setup.sh -o setup_docker.sh
	bash setup_docker.sh


## What will you have after install

### Boot2Docker

[boot2docker](http://boot2docker.io/) is a lightweight Linux distribution based on Tiny Core Linux made specifically to run Docker containers. It runs completely from RAM, weighs ~27MB and boots in ~5s (YMMV).

### Docker

[Docker](https://docker.com/) is an open platform for developers and sysadmins to build, ship, and run distributed applications.

### Container: [phensley/docker-dns](https://github.com/phensley/docker-dns)

DockerDNS watches the docker system for new containers. It then adds them to it's DNS server as *CONTAINERNAME.docker* allowing you direct access to them.

The Setup scripts maps port *53* to the Boot2Docker VM so the IP address will stay the same.

### Container: [progrium/logspout](https://github.com/progrium/logspout)

Logspout collects logs from all containers allowing you to view them together. Really useful for multi container apps.

The setup script start the service on port 80 on the *'log'* container. To stream all logs try the following command:

	curl http://log.docker/logs

Visit the [logspout](https://github.com/progrium/logspout) site for additional features.

### Container: [crosbymichael/dockerui](https://github.com/crosbymichael/dockerui)

DockerUI is a minimum Docker UI.

The setup script start the service on port 80 on the *'ui'* container. To see it open [http://ui.docker/](http://ui.docker/) using your browser.


## What The Script Does

 * Checks for MacOS X
 * Checks for VirtualBox
 * Checks for Boot2Docker
 * Checks for Docker
 * Initializes the boot2docker virtual machine if needed
 * Starts the boot2docker virtual machine if needed
 * Routes the 172.17.x.x using the boot2docker vm as gateway
 * Creates `/Library/LaunchDaemons/io.boot2docker.route.plist` to automatically create the 172.17.x.x routes on startup
 * Creates `/etc/resolver/docker` to use the boot2docker ip as dns server for `*.docker` domains
 * Creates and starts phensley/docker-dns under the name *'dns'*
 * Creates and starts progrium/logspout under the name *'log'*
 * Creates and starts crosbymichael/dockerui under the name *'ui'*
 * Gives you some text
