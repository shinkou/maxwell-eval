CREATE USER 'maxwell'@'%' IDENTIFIED BY 'maxwell-secret';
GRANT SELECT, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'maxwell'@'%';
CREATE DATABASE maxwell;
GRANT ALL on maxwell.* to 'maxwell'@'%';
FLUSH PRIVILEGES;
