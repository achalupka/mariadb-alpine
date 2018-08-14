#!/usr/bin/env bash
tfile=`mktemp`

cat << EOF > $tfile
CREATE DATABASE IF NOT EXISTS \`mysql\` CHARACTER SET utf8 COLLATE utf8_general_ci;
USE mysql;
FLUSH PRIVILEGES;
CREATE USER 'root'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
FLUSH PRIVILEGES;
EOF

mysqld --user=mysql --bootstrap --verbose=0 < $tfile