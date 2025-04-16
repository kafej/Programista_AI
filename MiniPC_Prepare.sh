#!/bin/bash

# Update package lists
sudo apt update

# Install MariaDB server
sudo apt install mariadb-server -y

# Secure MariaDB installation (set root password, remove anonymous users, etc.)
sudo mysql_secure_installation

# Log in to MariaDB as root
sudo mysql -u root -p

# Create the 'vault' database
CREATE DATABASE vault;

# Use the 'vault' database
USE vault;

# Create the 'vault' table
CREATE TABLE vault (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request TEXT,
    answer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    done VARCHAR(3) NOT NULL DEFAULT 'no'
);

ALTER USER 'root'@'localhost' IDENTIFIED BY 'Qwerty123';

# Exit MariaDB
exit;

echo "MariaDB installed and databases 'vault' and 'local_vault' created successfully. Password for root is Qwerty123. Please Change it."
