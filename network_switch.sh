#!/bin/bash

# Check if mysql is installed
if ! command -v mysql &> /dev/null
then
  echo "MySQL is not installed. Exiting script. Please install it."
  exit 1
fi

# This need to be yours DB info
DB_HOST="192.168.50.72"
DB_USER="external"
DB_PASSWORD="Qwerty123"
DB_NAME="vault"

# Network Interface Names
INTRA_IFACE="eth0"
VAULT_IFACE="eth1"

# Function to check network status
check_network_status() {
  # Check if Intranet is down and Vault is up
  INTRA_UP=$(ip link show "$INTRA_IFACE" | grep -q "state UP")
  VAULT_UP=$(ip link show "$VAULT_IFACE" | grep -q "state UP")

  if ip link show "$INTRA_IFACE" | grep -q "state UP" && ip link show "$VAULT_IFACE" | grep -q "state UP"; then
    # Run network_switch.sh
    ip link set "$VAULT_IFACE" down
  fi

}

# Run the function
check_network_status

# Function to check database and switch networks
switch_networks() {
  # Check if any rows have "no" in the "done" column
  HAS_NO=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -s -N -e "SELECT done FROM requests ORDER BY id DESC LIMIT 1;" | grep "no")

  if [ -n "$HAS_NO" ]; then
    # Down Intranet, Up Vault
    ip link set "$INTRA_IFACE" down
    ip link set "$VAULT_IFACE" up
    echo "Switched to Vault network."
    bash /home/kafej/Pulpit/network_monitor.sh
    exit 0
  else
    # Down Vault, Up Intranet
    ip link set "$VAULT_IFACE" down
    ip link set "$INTRA_IFACE" up
    echo "Switched to Intranet network."
  fi
}

# Run the function
switch_networks

# Loop indefinitely, checking network status every 5 seconds
while true; do
  switch_networks
  sleep 5
done

