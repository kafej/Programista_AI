Add-Type -Path "C:\Users\Kafej\Desktop\MySql.Data.dll"

$PassFilePath = ".\pass.txt"

if (Test-Path -Path $PassFilePath) {
    $PassNew = Get-Content -Path ".\pass.txt"
  } else {
    $PassNew = "Qwerty123"
  }

# Database connection details to MiniPC
$server = "172.24.87.120"
$database = "vault"
$user = "vault"

$connectionString = "Server=$server;Database=$database;Uid=$user;Pwd=$PassNew;"

$Command = New-Object MySql.Data.MySqlClient.MySqlCommand
$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
$query = "SELECT id,request FROM requests WHERE done = 'no' ORDER BY ID DESC LIMIT 1"

$Command.Connection = $conn

$Command.Connection.Open()
$command=$conn.CreateCommand()
$command.CommandText=$query
$wynik = $command.ExecuteReader()
    
$tablec = new-object System.Data.DataTable
$tablec.Load($wynik)

$requestid = $tablec | Select-Object -ExpandProperty id
$request = $tablec | Select-Object -ExpandProperty request

$conn.close()

if ($request) {
    ollama run ProgramistaJarvis:latest "$request" >> answer.txt

    (Get-Content -Path ".\answer.txt" -RAW) -replace "`r`n|`n|`r", "" | Set-Content -Path ".\answer.txt"
    (Get-Content -Path ".\answer.txt" -RAW) -replace "'", "" | Set-Content -Path ".\answer.txt"
    $answer = Get-Content .\answer.txt
    Remove-Item .\answer.txt -Force

    # Connection string
    $connectionString2 = "Server=$server;Database=$database;Uid=$user;Pwd=$PassNew;"

    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString2)
    $connection.Open()

    $query = "UPDATE requests SET answer = '$answer' WHERE id = $requestid;"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    $connection.Close()

    # Database connection details to MiniPC
    $database = "local_vault"

    # Connection string
    $connectionString2 = "Server=$server;Database=$database;Uid=$user;Pwd=$PassNew;"

    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString2)
    $connection.Open()

    $query = "INSERT INTO requests (id_ag, answer, done) VALUES ('$requestid', '$answer', 'yes');"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    $connection.Close()

    Remove-Item -Path ".\pass.txt" -Force

    # Define the character set
    $CharacterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    # Define the password length
    $PasswordLength = 8

    # Generate the password
    $Password = ""
    for ($i = 0; $i -lt $PasswordLength; $i++) {
        $RandomIndex = Get-Random -Maximum $CharacterSet.Length
        $Password += $CharacterSet[$RandomIndex]
    }

    $password | Out-File -FilePath ".\pass.txt" -Encoding utf8

    # Connection string
    $connectionString3 = "Server=$server;Uid=$user;Pwd=$PassNew;"

    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString3)
    $connection.Open()

    $query = "SET PASSWORD FOR 'vault'@'%' = PASSWORD('$password'); FLUSH PRIVILEGES;"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    $connection.Close()

    # Database connection details to MiniPC
    $database = "vault"

    # Connection string
    $connectionString2 = "Server=$server;Database=$database;Uid=$user;Pwd=$PassNew;"

    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString2)
    $connection.Open()

    $query = "UPDATE requests SET done = 'yes' WHERE id = $requestid;"

    $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
    $command.ExecuteNonQuery()

    $connection.Close()

}
