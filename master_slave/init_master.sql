CREATE USER 'repl'@'%' IDENTIFIED BY 'repl-secret';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
