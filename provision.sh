#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Updating System Repositories..."
sudo apt-get update -qq &> /dev/null 2>&1

#Set the language correctly

LOCALE="en_GB.UTF-8"

sudo apt-get install -y -qq language-pack-en-base &> /dev/null 2>&1

sudo locale-gen &> /dev/null 2>&1

sudo sed -i "s/LANG=\"en_US.UTF-8\"/LANG=\"$LOCALE\"/g" /etc/default/locale &> /dev/null 2>&1

#Set VAGRANT_SKIP_UPGRADE To skip upgrades - useful for quickly testing stuff
#VAGRANT_SKIP_UPGRADE=""
if [ -z "${VAGRANT_SKIP_UPGRADE+x}"]
then
  echo "Upgrading Software (this might take a while)..."
  sudo apt-get upgrade -y -qq &> /dev/null 2>&1
  sudo apt-get dist-upgrade -y -qq &> /dev/null 2>&1
  sudo apt-get autoremove -y -qq &> /dev/null 2>&1
fi
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root' &> /dev/null 2>&1
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root' &> /dev/null 2>&1

sudo apt-get install -y -qq zsh vim git curl wget python-software-properties &> /dev/null 2>&1

#Set the default shell to zsh and change the zsh theme to agnoster
sudo su vagrant -c 'curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh > install.sh && sudo chmod +x install.sh && sed -i "s/chsh -s/sudo chsh -s/g" "/home/$(whoami)/install.sh" && sed -i "s/env zsh/\#env zsh/g" "/home/$(whoami)/install.sh" && /home/$(whoami)/install.sh && sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g" "/home/$(whoami)/.zshrc" && rm -rf "/home/$(whoami)/install.sh" && sudo chsh $(whoami) -s /usr/bin/zsh && sudo ln -s /home/$(whoami)/.oh-my-zsh /root && sudo ln -s /home/$(whoami)/.zshrc /root' &> /dev/null 2>&1

sudo add-apt-repository -y ppa:ondrej/php &> /dev/null 2>&1
sudo apt-get update -qq &> /dev/null 2>&1
if [ -z "${VAGRANT_SKIP_UPGRADE+x}"]
then
  sudo apt-get upgrade -qq &> /dev/null 2>&1
fi

echo "Installing LEMP Stack..."

#Install LEMP Stack
sudo apt-get install -y -f php-mbstring php-gettext php5.6-mbstring php5.6-gettext php5.6-fpm php5.6-cgi php5.6-common php5.6-cli nginx nginx-common php5.6-curl php5.6-gd php5.6-mcrypt php5.6-readline mariadb-server php5.6-mysql git-core php5.6-xdebug &> /dev/null 2>&1

update-rc.d nginx defaults  &> /dev/nul 2>&1 #Enable nginx
update-rc.d mysql defaults &> /dev/null 2>&1 #Enable mysql server

#Set mariadb to listen on all interfaces (0.0.0.0)
sudo sed -i "s/bind-address\t\t= 127.0.0.1/bind-address\t\t= 0.0.0.0/g" /etc/mysql/my.cnf
sudo mysql -u root --password=root --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.99.%' IDENTIFIED BY 'root' WITH GRANT OPTION;"
sudo mysql -u root --password=root --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root' WITH GRANT OPTION;"
sudo mysql -u root --password=root --execute="CREATE USER root IDENTIFIED VIA unix_socket;"
sudo mysql -u root --password=root --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED VIA unix_socket;"
sudo systemctl restart mysql

#Install phpmyadmin - Thanks StackOverflow (https://stackoverflow.com/questions/22440298/preseeding-phpmyadmin-skip-multiselect-skip-password)
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect none'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-user string root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'

sudo apt-get install -y -qq --no-install-recommends phpmyadmin &> /dev/null 2>&1

# Fix mysql user / password - This shouldn't be needed since it's done above but for some
# reason is reset / ignored after installing phpmyadmin
sudo mysql -u root --password=root --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root' WITH GRANT OPTION;"

#Install Composer PHP dependancy manager
curl -sS https://getcomposer.org/installer | php &> /dev/null 2>&1
sudo mv composer.phar /usr/local/bin/composer &> /dev/null 2>&1

#sudo cp -R /etc/nginx /vagrant/test
sudo rm -rf /usr/share/nginx &> /dev/null 2>&1
sudo rm -rf /etc/nginx &> /dev/null 2>&1

sudo ln -fs /vagrant/www /usr/share/nginx &> /dev/null 2>&1
sudo ln -fs /usr/share/phpmyadmin /usr/share/nginx/ &> /dev/null 2>&1
sudo ln -fs /usr/share/nginx/phpmyadmin /usr/share/nginx/html &> /dev/null 2>&1
sudo ln -fs /vagrant/etc/nginx /etc/nginx &> /dev/null 2>&1
sudo mkdir -p /etc/nginx/sites-enabled &> /dev/null 2>&1
sudo ln -fs /vagrant/etc/nginx/sites-available/default /etc/nginx/sites-enabled/ &> /dev/null 2>&1

echo "Restarting PHP and Nginx..."
sudo phpenmod -v ALL mcrypt
sudo systemctl restart php5.6-fpm
sudo systemctl restart nginx

echo "Setup Complete\!"

echo "IP Address: $(/sbin/ifconfig enp0s8 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"

echo "Add this line to your hosts file (either /etc/hosts or %WINDIR%\System32\drivers\etc\hosts on Windows) to access the box via hostname"

echo "$(/sbin/ifconfig enp0s8 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')    hostname"

echo "You can do this with bash (to check if you have bash installed simply run 'bash --version') as follows:"

echo "sudo bash -c 'printf \"$(/sbin/ifconfig enp0s8 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')    hostname\" >> /etc/hosts'"

echo "You can do this automatically via the vagrant-hostmanager plugin (see: https://github.com/smdahlen/vagrant-hostmanager)"

exit 0
