# DockerBootstrapOSX

 * [Description](#description)
 * [Quick Install](#quick-install)
 * [What will you have after install](#what-will-you-have-after-install)
 * [Usage](#usage)
   * [Further Reading](#further-reading)
 * [What The Script Does](#what-the-script-does)
 * [Uninstalling](#uninstalling)
 * [Credits](#credits)


## Description

DockerBootstrapOSX is a little bootstrapping script that automates the installation of a Docker environment on a MacOS X machine.

### Warning

Do not use [Kitematic](kitematic.com) and plain Boot2Docker alongside each other. They will conflict with each other forcing a reinstall from scratch. Kitematic is a great product and good for those who wish to use Docker containers for development. You *can* make them work alongside each other but it's a bit fiddly of a work and you need some Docker internals knowledge. For beginners it's best to choose either.

## Quick Install

Make sure you have the latest version of [VirtualBox](http://virtualbox.org/wiki/Downloads), Docker and Boot2Docker installed. I personally install using [Homebrew](http://brew.sh) with `brew install docker boot2docker`.

Then run the following commands:

```console
curl -s https://raw.githubusercontent.com/JonGretar/DockerBootstrapOSX/master/setup.sh -o setup_docker.sh
bash setup_docker.sh
```

## What will you have after install

### Boot2Docker

[boot2docker](http://boot2docker.io/) is a lightweight Linux distribution based on Tiny Core Linux made specifically to run Docker containers. It runs completely from RAM, weighs ~27MB and boots in ~5s (YMMV).

### Docker

[Docker](https://docker.com/) is an open platform for developers and sysadmins to build, ship, and run distributed applications.

### Container: [phensley/docker-dns](https://github.com/phensley/docker-dns)

DockerDNS watches the docker system for new containers. It then adds them to it's DNS server as `CONTAINERNAME.docker` allowing you direct access to them.

The Setup scripts maps port *53* to the Boot2Docker VM so the IP address will stay the same. It then adds the dns server as a handler for `*.docker` domains

### Container: [progrium/logspout](https://github.com/progrium/logspout)

Logspout collects logs from all containers allowing you to view them together. Really useful for multi container apps.

The setup script start the service on port 80 on the *'log'* container. To stream all logs try the following command:

	curl http://log.docker/logs

Visit the [logspout](https://github.com/progrium/logspout) site for additional features.

### Container: [crosbymichael/dockerui](https://github.com/crosbymichael/dockerui)

DockerUI is a minimum Docker UI.

The setup script start the service on port 80 on the *'ui'* container. To see it open [http://ui.docker/](http://ui.docker/) using your browser.

## Usage

To shut down the virtual machine(it does take a bit of memory) use the command `boot2docker down` and to start it up again use `boot2docker up`.

The containers may not start up automatically with the VM. To start them use the command `docker start dns log ui`.

Now read up on Docker. It's pretty simple to get started from this point.

### Further Reading

 * [Flurdy: Basic Docker](http://flurdy.com/docs/docker/docker_osx_ubuntu.html#docker)
 * [Kitematic: Understanding Docker Volumes ](http://kitematic.com/blog/2014/09/10/understanding-docker-volumes.html)
 * [LinuxMeerkat: Docker Tutorial](http://linuxmeerkat.wordpress.com/2014/07/21/docker-tutorial/)
 * [Spritle: Beginners guide to Docker](http://www.spritle.com/blogs/2013/08/23/docker-for-beginners/)
 * [DigitalOcean: Docker Explained: How To Containerize Python Web  pplications](https://www.digitalocean.com/community/tutorials/docker-explained-how-to-containerize-python-web-applications)
 * [ServersForHackers: Getting Started with Docker](https://serversforhackers.com/articles/2014/ 3/20/getting-started-with-docker/)
 * [Official Docker User Guide](https://docs.docker.com/userguide/)
 * [The Docker Book](http://dockerbook.com/)
 * [Dockerfile  mages](http://dockerfile.github.io/)
 * [Official Docker Registry](https://registry.hub.docker.com/)
 * [YouTube: Docker 101 Tutorial](https://www.youtube.com/watch?v=VeiUjkiqo9E)
 * [Partial Continuous Deployment With Docker and SaltStack](http://bitjudo.com/blog/2014/05/13/partial-continuous-deployment-with-docker-and-saltstack/)


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

## Uninstalling

To completely remove all this script does issue the following commands:

```console
boot2docker down
boot2docker delete
sudo rm /Library/LaunchDaemons/io.boot2docker.route.plist
sudo rm /etc/resolver/docker
```

## Credits

This script was created by using scripts and info from these 2 sources:

 * https://github.com/frosenberg/docker-dns-scripts
 * https://github.com/kitematic/kitematic

This is really mostly their work. I just merged it and packaged.
