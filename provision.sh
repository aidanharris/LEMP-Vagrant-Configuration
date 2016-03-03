export DEBIAN_FRONTEND=noninteractive

echo "Updating System Repositories..."
sudo apt-get update -qq &> /dev/null 2>&1

#Set the language correctly

LOCALE="en_GB.UTF-8"

sudo apt-get install -y -qq language-pack-en-base &> /dev/null 2>&1

sudo locale-gen &> /dev/null 2>&1

sudo sed -i "s/LANG=\"en_US.UTF-8\"/LANG=\"$LOCALE\"/g" /etc/default/locale &> /dev/null 2>&1

echo "Upgrading Software (this might take a while)..."
sudo apt-get upgrade -y -qq &> /dev/null 2>&1
sudo apt-get dist-upgrade -y -qq &> /dev/null 2>&1
sudo apt-get autoremove -y -qq &> /dev/null 2>&1

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root' &> /dev/null 2>&1
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root' &> /dev/null 2>&1

sudo apt-get install -y -qq zsh vim git curl wget python-software-properties &> /dev/null 2>&1

#Set the default shell to zsh and change the zsh theme to agnoster
sudo su vagrant -c 'curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh > install.sh && sudo chmod +x install.sh && sed -i "s/chsh -s/sudo chsh -s/g" "/home/$(whoami)/install.sh" && sed -i "s/env zsh/\#env zsh/g" "/home/$(whoami)/install.sh" && /home/$(whoami)/install.sh && sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/g" "/home/$(whoami)/.zshrc" && rm -rf "/home/$(whoami)/install.sh" && sudo chsh $(whoami) -s /usr/bin/zsh && sudo ln -s /home/$(whoami)/.oh-my-zsh /root && sudo ln -s /home/$(whoami)/.zshrc /root' &> /dev/null 2>&1

sudo add-apt-repository -y ppa:ondrej/php5 &> /dev/null 2>&1
sudo apt-get update -qq &> /dev/null 2>&1

#Install LEMP Stack
sudo apt-get install -y -f php5-fpm php5-cgi php5-common php5-cli nginx nginx-common php5-curl php5-gd php5-mcrypt php5-readline mariadb-server php5-mysql git-core php5-xdebug &> /dev/null 2>&1

update-rc.d nginx defaults  &> /dev/nul 2>&1 #Enable nginx
update-rc.d mysql defaults &> /dev/null 2>&1 #Enable mysql server

#Install Composer PHP dependancy manager
curl -sS https://getcomposer.org/installer | php &> /dev/null 2>&1
sudo mv composer.phar /usr/local/bin/composer &> /dev/null 2>&1

#sudo cp -R /etc/nginx /vagrant/test
sudo rm -rf /usr/share/nginx &> /dev/null 2>&1
sudo rm -rf /etc/nginx &> /dev/null 2>&1

sudo ln -fs /vagrant/www /usr/share/nginx &> /dev/null 2>&1
sudo ln -fs /vagrant/etc/nginx /etc/nginx &> /dev/null 2>&1
sudo mkdir -p /etc/nginx/sites-enabled &> /dev/null 2>&1
sudo ln -fs /vagrant/etc/nginx/sites-available/default /etc/nginx/sites-enabled/ &> /dev/null 2>&1

echo "Restarting PHP and Nginx..."

sudo service php5-fpm restart
sudo service nginx restart

echo "Setup Complete\!"

echo "IP Address: $(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')"

echo "Add this line to your hosts file (either /etc/hosts or %WINDIR%\System32\drivers\etc\hosts on Windows) to access the box via hostname"

echo "$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')    hostname"

echo "You can do this with bash (to check if you have bash installed simply run 'bash --version') as follows:"

echo "sudo bash -c 'printf \"$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')    hostname\" >> /etc/hosts'"

echo "You can do this automatically via the vagrant-hostmanager plugin (see: https://github.com/smdahlen/vagrant-hostmanager)"

exit 0