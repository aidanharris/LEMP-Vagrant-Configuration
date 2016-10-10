# LEMP-Vagrant-Configuration
Creates a LEMP stack using Vagrant

See [provision.sh](https://github.com/aidanharris/LEMP-Vagrant-Configuration/blob/master/provision.sh) for details how the box is provisioned. The TLDR is it pulls in Ubuntu Xenial, Installs NGINX, PHP and MariaDB and also installs and changes the shell to ZSH and configures ZSH using [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh).

The file [services.sh](https://github.com/aidanharris/LEMP-Vagrant-Configuration/blob/master/services.sh) is set to run everytime `vagrant up` runs and starts the nginx and mariadb service. This is needed due to the fact that the services will not start automatically due to the shared folder not yet being mounted.

## Usage

* Install [Vagrant](https://vagrantup.com)
* Clone this repository (`git clone https://github.com/aidanharris/LEMP-Vagrant-Configuration.git`)
* Cd into the repository (`cd LEMP-Vagrant-Configuration`)
* `vagrant up`
* That's It!
