Add-Type -Path "C:\Users\Kafej\Desktop\MySql.Data.dll"

# Database connection details
$server = "localhost"
$database = "local_vault"
$user = "root"
$password = ""

# Connection string
$connectionString = "Server=$server;Uid=$user;Pwd=$password;"

# Create the database if it doesn't exist
try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()

    # Check if the database exists
    $query = "CREATE DATABASE IF NOT EXISTS local_vault;"
    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Database 'local_vault' created or already exists."
}
catch {
    Write-Host "Error creating database on AI side: $($_.Exception.Message)"
    exit
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

# Connection string
$connectionString2 = "Server=$server;Database=$database;Uid=$user;Pwd=$password;"

# Now, create the table if it doesn't exist
try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString2)
    $connection.Open()

$query = @"
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ag INT,
    request TEXT,
    answer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    done VARCHAR(255) DEFAULT 'no'
);
"@

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Table 'requests' created or already exists."
}
catch {
    Write-Host "Error creating table on AI side: $($_.Exception.Message)"
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

# Database connection details to MiniPC
$server = "172.24.87.120"
$database = "local_vault"
$user = "root"
$password = "Qwerty123"

# Connection string
$connectionString = "Server=$server;Uid=$user;Pwd=$password;"

# Create the database if it doesn't exist
try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()

    # Check if the database exists
    $query = "CREATE DATABASE IF NOT EXISTS `local_vault`;"
    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Database 'local_vault' created or already exists."
}
catch {
    Write-Host "Error creating database: $($_.Exception.Message)"
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

# Connection string
$connectionString2 = "Server=$server;Database=$database;Uid=$user;Pwd=$password;"

# Now, create the table if it doesn't exist
try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString2)
    $connection.Open()

$query = @"
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ag INT,
    request TEXT,
    answer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    done VARCHAR(255) DEFAULT 'no'
);
"@

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Table 'requests' created or already exists."
}
catch {
    Write-Host "Error creating table: $($_.Exception.Message)"
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

# Create user
try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()

    $query = "CREATE USER 'vault'@'%' IDENTIFIED BY 'Qwerty1234';"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "User 'vault' created or already exists."
}
catch {
    Write-Host "Error creating user: $($_.Exception.Message)"
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()

    $query = "GRANT ALL PRIVILEGES ON vault.* TO 'vault'@'%' IDENTIFIED BY 'Qwerty1234' WITH GRANT OPTION;"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Grant all privileges to vault."
}
catch {
    Write-Host "Error adding privileges for vault for vault database: $($_.Exception.Message)"
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()

    $query = "GRANT ALL PRIVILEGES ON local_vault.* TO 'vault'@'%' IDENTIFIED BY 'Qwerty1234' WITH GRANT OPTION;"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Grant all privileges to local_vault."
}
catch {
    Write-Host "Error adding privileges for vault for local_vault database: $($_.Exception.Message)"
}
finally {
    if ($connection) {
        $connection.Close()
    }
}

# Flush privileges
try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()

    $query = "FLUSH PRIVILEGES;"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    Write-Host "Flush privileges."
}
catch {
    Write-Host "Error creating database: $($_.Exception.Message)"
}

finally {
    if ($connection) {
        $connection.Close()
    }
}