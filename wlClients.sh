#!/bin/sh

# wlClients.sh
# Counts connected (associated) Wi-Fi devices
# Arguments: target interface. Assumes all interfaces if no argument
# Auto-generates wlInterfaces.txt if it doesn't exist

# Get path to this script
scriptdir=$(dirname "$(readlink -f -- "$0")")
interfaces_file="$scriptdir/wlInterfaces.txt"

# Function to auto-detect and generate wlInterfaces.txt
generate_interfaces_file() {
	local tmpfile="$interfaces_file.tmp"
	
	# Find all wireless interfaces
	for dev in /sys/class/net/*; do
		iface=$(basename "$dev")
		# Check if it's a wireless interface
		if [ -d "$dev/wireless" ] || [ -d "$dev/phy80211" ]; then
			# Try to get SSID
			ssid=$(/usr/sbin/iw dev "$iface" info 2>/dev/null | /bin/grep ssid | /usr/bin/cut -f 2 -s -d" " | /usr/bin/tr -d '\n')
			# If no SSID (interface down or no SSID set), use empty string
			[ -z "$ssid" ] && ssid=""
			echo "$iface,$ssid" >> "$tmpfile"
		fi
	done
	
	# Only replace if we found interfaces
	if [ -s "$tmpfile" ]; then
		mv "$tmpfile" "$interfaces_file"
		return 0
	else
		rm -f "$tmpfile"
		return 1
	fi
}

# Check if wlInterfaces.txt exists, generate if not
if [ ! -f "$interfaces_file" ]; then
	generate_interfaces_file
	if [ $? -ne 0 ]; then
		/bin/echo "Error: Could not generate $interfaces_file and file does not exist"
		exit 1
	fi
fi

# Check number of arguments
if [ $# -gt 1 ]; then
	/bin/echo "Usage: wlClients.sh [interface]"
	/bin/echo "Too many command line arguments, exiting."
	exit 1
fi

# Get interface list. Set target, which is name returned for interface
if [ "$1" ]; then
	interfaces=$1
else
	interfaces=$(cat "$interfaces_file" | cut -f 1 -d",")
fi

# Count associated devices
count=0
for interface in $interfaces
do
	new=$(/usr/sbin/iw dev "$interface" station dump 2>/dev/null | /bin/grep Station | /usr/bin/cut -f 2 -s -d" " | /usr/bin/wc -l)
	count=$(( count + new ))
done

# Return snmp result
/bin/echo $count
