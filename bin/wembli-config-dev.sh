cd ~/
sudo chkconfig iptables off
sudo service iptables stop
wget http://mirror-fpt-telecom.fpt.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
sudo yum install -y epel jq nodejs npm nginx mongodb
sudo rm -rf /etc/nginx
sudo ln -s /wembli/nginx/vagrant /etc/nginx
mkdir -p /var/lib/nginx/proxy
sudo chmod -R 777 /var/lib/nginx/proxy
service nginx restart
#get the ip addresses for the docker containers so the app can use them
mkdir -p /wembli/config
docker ps | grep mongodb | cut -d' ' -f1 | xargs docker inspect | jq -r {host:.[0].NetworkSettings.IPAddress} > /wembli/config/mongodb.json
docker ps | grep redis | cut -d' ' -f1 | xargs docker inspect | jq -r {host:.[0].NetworkSettings.IPAddress} > /wembli/config/redis.json
#install website node_modules
sudo npm install -g nodemon
cd /wembli/website
npm install
mkdir logs
cd /wembli/express-meta-tags
npm install
#load the directory into redis
REDIS_HOST=$(cat /wembli/config/redis.json | jq -r .host)
node /wembli/website/bin/directory/build-tree.js -h $REDIS_HOST /wembli/website/bin/directory/tmp.csv
#load the meta tags into redis
node /wembli/express-meta-tags/bin/bulk-load.js -h $REDIS_HOST /wembli/website/data/Wembli\ Meta\ Tags.csv
#ticket network api proxy
sudo echo "184.106.146.14 tn.wembli.com" >> /etc/hosts
sudo echo "export PATH=/wembli/geoip/bin:/wembli/node/bin:/wembli/website/node_modules/less/bin:$PATH:$HOME/bin" >> /home/vagrant/.bashrc
sudo echo "export NODE_ENV=development" >> /home/vagrant/.bashrc
sudo echo "export NODE_PATH=/wembli/node/lib/node_modules:/wembli/node/lib:/wembli/website/lib:/wembli/website/models" >> /home/vagrant/.bashrc

