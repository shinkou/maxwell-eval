CHANGE MASTER TO
	MASTER_HOST='maxwell-mysql-master'
	, MASTER_USER='repl'
	, MASTER_PASSWORD='repl-secret'
	, MASTER_LOG_FILE='mysql-bin.000001'
	, MASTER_LOG_POS=154
;

START SLAVE;

CREATE USER 'maxwell'@'%' IDENTIFIED BY 'maxwell-secret';
GRANT SELECT, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'maxwell'@'%';
CREATE DATABASE maxwell;
GRANT ALL on maxwell.* to 'maxwell'@'%';
FLUSH PRIVILEGES;
