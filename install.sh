mkdir src
cd src
git clone https://github.com/bluesman/express-meta-tags.git
git clone https://github.com/bluesman/wembli-nginx.git nginx
git clone https://github.com/bluesman/wembli-website.git website
cd website
git checkout vagrant
vagrant up