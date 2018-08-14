#!/bin/bash
set -e

if [ ! -d '/var/lib/mysql/mysql' -a "${1%_safe}" = 'mysqld' ]; then

	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# These statements _must_ be on individual lines, and _must_ end with
	# semicolons (no line breaks or comments are permitted).
	# TODO proper SQL escaping on ALL the things D:
	TEMP_FILE='/tmp/mysql-first-time.sql'
	cat > "$TEMP_FILE" <<-EOSQL
		DELETE FROM mysql.user ;
		FLUSH PRIVILEGES;
		CREATE USER 'root'@'%' IDENTIFIED BY 'password' ;
		GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.0%';
        GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
        UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
		DROP DATABASE IF EXISTS test ;
		FLUSH PRIVILEGES;
	EOSQL

	if [ "$MYSQL_DATABASE" ]; then
		echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci;" >> "$TEMP_FILE"
	fi

	if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
		echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$TEMP_FILE"

		if [ "$MYSQL_DATABASE" ]; then
			echo "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' ;" >> "$TEMP_FILE"
		fi
	fi

	echo 'FLUSH PRIVILEGES ;' >> "$TEMP_FILE"

	set -- "$@" --init-file="$TEMP_FILE"
fi

chown -R mysql:mysql /var/lib/mysql
exec "$@"