mysql -u root -e "CREATE USER 'typo3'@'localhost' IDENTIFIED BY 'typo3';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'typo3'@'localhost' WITH GRANT OPTION;"
