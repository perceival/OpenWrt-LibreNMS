# OpenWrt-LibreNMS
SNMPD OpenWrt configuration - integration for OpenWrt devices to be visible wtih more features in LibreNMS network management platform. Based on https://github.com/librenms/librenms-agent/tree/master/snmp/Openwrt

This package provides unified, auto-detecting SNMP monitoring for OpenWrt devices with support for:
- Wireless interface metrics (clients, frequency, rate, noise, SNR)
- Thermal sensor monitoring (broken)
- Auto-discovery of wireless interfaces
- Dynamic configuration generation

## Key Features

### 1. Auto-Generation of wlInterfaces.txt

`wlClients.sh` auto-detects all wireless interfaces on first run and generates the file automatically.

```bash
# First run automatically creates wlInterfaces.txt
/etc/librenms/wlClients.sh
```

### 2. Dynamic Config Generator
**Problem**: Different devices need different snmpd configs based on their wireless interfaces (ap1: wl0-ap0, wl1-ap0; ap2: wlan0, wlan02, wlan12, wlan22).

**Solution**: `snmpd-config-generator.sh` reads wlInterfaces.txt and generates appropriate UCI config entries for all detected interfaces.

```bash
# Generate config for current device
/etc/librenms/snmpd-config-generator.sh
```

### 3. Unified Base Configuration
**Problem**: Repetitive config entries across devices.

**Solution**: `snmpd-base-config` provides a common base with placeholders for dynamic content.

### 4. Error Handling
All scripts have:
- Error messages
- Argument validation
- Fallback behavior
- Consistent exit codes
