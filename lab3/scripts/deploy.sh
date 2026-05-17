#!/bin/bash

set -e

echo "== Updating system =="
apt update && apt upgrade -y

echo "== Installing packages =="
apt install -y curl openjdk-17-jdk mariadb-server nginx

echo "== Creating users =="
id student || useradd -m -s /bin/bash student
id teacher  || useradd -m -s /bin/bash teacher
id operator || useradd -m -s /bin/bash -g operator operator
id app  || useradd --system --no-create-home --shell /usr/sbin/nologin app

echo "student:12345678" | chpasswd
echo "teacher:12345678" | chpasswd
echo "operator:12345678" | chpasswd

chage -d 0 student
chage -d 0 teacher
chage -d 0 operator

usermod -aG sudo student
usermod -aG sudo teacher

echo "== Configuring MariaDB =="

systemctl enable mariadb
systemctl start mariadb

mysql -e "CREATE DATABASE IF NOT EXISTS mywebapp;"
mysql -e "CREATE USER IF NOT EXISTS 'mywebapp_user'@'localhost' IDENTIFIED BY 'strongpassword';"
mysql -e "GRANT ALL PRIVILEGES ON mywebapp.* TO 'mywebapp_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "== Deploying app =="

mkdir -p /opt/mywebapp
cp /home/student/mywebapp/lab1/target/mywebapp-1.0-SNAPSHOT.jar /opt/mywebapp/app.jar
cp /home/student/mywebapp/lab1/migrate.sql /opt/mywebapp/

chown -R app:app /opt/mywebapp
chmod 750 /opt/mywebapp

echo "== Creating DB config =="

cat <<EOF > /opt/mywebapp/db.conf
[client]
user=mywebapp_user
password=strongpassword
database=mywebapp
EOF

chown app:app /opt/mywebapp/db.conf
chmod 600 /opt/mywebapp/db.conf

echo "== Creating systemd socket =="

cat <<EOF > /etc/systemd/system/mywebapp.socket
[Unit]
Description=MyWebApp Socket

[Socket]
ListenStream=127.0.0.1:3000
NoDelay=true

[Install]
WantedBy=sockets.target
EOF

echo "== Creating systemd service =="

cat <<EOF > /etc/systemd/system/mywebapp.service
[Unit]
Description=My Web App
After=network.target mariadb.service

[Service]
User=app
WorkingDirectory=/opt/mywebapp
ExecStartPre=/bin/bash -c 'cat /opt/mywebapp/migrate.sql | /usr/bin/mysql --defaults-extra-file=/opt/mywebapp/db.conf mywebapp'
ExecStart=/usr/bin/java -jar /opt/mywebapp/app.jar
#explanation of why the socket implementation is commented out is in README
#StandartInput=socket
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable mywebapp.service
systemctl start mywebapp.service
#systemctl enable mywebapp.socket
#systemctl start mywebapp.socket

echo "== Configuring nginx =="

cat <<EOF > /etc/nginx/sites-available/mywebapp
server {
    listen 80;
    server_name _;

    access_log /var/log/nginx/mywebapp_access.log;
    error_log /var/log/nginx/mywebapp_error.log;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;

        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /tasks {
    	proxy_pass http://127.0.0.1:3000;
    }

    location /health {
    	proxy_pass http://127.0.0.1:3000;
    }

    location ~* ^/(?!($|tasks|health)) {
    	return 403;
    }
}
EOF

ln -sf /etc/nginx/sites-available/mywebapp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx


echo "== Configuring operator sudo =="

cat <<EOF > /etc/sudoers.d/operator
operator ALL=(ALL) NOPASSWD: /bin/systemctl start mywebapp, /bin/systemctl stop mywebapp, /bin/systemctl restart mywebapp, /bin/systemctl status mywebapp, /bin/systemctl reload nginx
EOF

chmod 440 /etc/sudoers.d/operator

echo "== Creating gradebook =="

echo "22" > /home/student/gradebook
chown student:student /home/student/gradebook

echo "== Disabling default user =="

usermod -L user || true

echo "== DONE =="
