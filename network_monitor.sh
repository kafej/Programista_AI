#!/bin/bash

# This need to be yours DB info
DB_HOST="localhost"
DB_USER="external"
DB_PASSWORD="Qwerty123"
DB_NAME="vault"

# Network Interface Names
INTRA_IFACE="eth0"
VAULT_IFACE="eth1"

# Function to check database and switch networks
switch_networks_status() {
  # Check if any rows have "no" in the "done" column
  HAS_YES=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -s -N -e "SELECT done FROM requests ORDER BY id DESC LIMIT 1;" | grep "yes")

  if [ -n "$HAS_YES" ]; then
    # Down Intranet, Up Vault
    ip link set "$INTRA_IFACE" up
    ip link set "$VAULT_IFACE" down
    echo "Switched to Intranet network."
    bash /home/kafej/Pulpit/network_switch.sh
    exit 0
  fi
}

# Run the function
switch_networks_status

# Loop indefinitely, checking network status every 5 seconds
while true; do
  switch_networks_status
  sleep 5
done
