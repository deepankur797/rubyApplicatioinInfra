#! /bin/bash

sudo apt-get update
sudo apt-get install -y nginx
sudo service nginx restart
sleep 10
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates
#sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main" | sudo tee /etc/apt/sources.list.d/passenger.list
sudo apt update
sleep 10
sudo apt-get install -y libnginx-mod-http-passenger
if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi
sudo ls /etc/nginx/conf.d/mod-http-passenger.conf
sudo service nginx restart

sudo sed '24i \\tpassenger_enabled on;\n\tpassenger_ruby /usr/bin/ruby2.7;' /etc/nginx/sites-enabled/default > output.txt
sudo rm -rf /etc/nginx/sites-enabled/default
sudo mv /output.txt /etc/nginx/sites-enabled/default
sleep 10

git clone https://github.com/atvenu/AssignmentDemoRailsApplication.git
sudo apt install -y ruby-full
sudo apt-get install -y build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
sleep 10
sudo gem install bundler:1.16.1
sleep 15
sudo sed -i 's/root \/var\/www\/html/root \/AssignmentDemoRailsApplication\/public/g'  /etc/nginx/sites-enabled/default
cd /AssignmentDemoRailsApplication
sudo bundle install
sleep 60

sudo sed -e '/secret_key_base: </ s/^#*/#/' -i /AssignmentDemoRailsApplication/config/secrets.yml
sudo chmod 777 /AssignmentDemoRailsApplication/config/secrets.yml
sudo echo "  secret_key_base: bhasd34asd">>/AssignmentDemoRailsApplication/config/secrets.yml
sudo service nginx restart
