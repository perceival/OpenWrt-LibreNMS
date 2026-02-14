# OpenWrt SNMPD Monitoring - Final Package

## Complete File List

### Core Scripts (Required)
- **wlClients.sh** - Count Wi-Fi clients, auto-generates wlInterfaces.txt
- **wlFrequency.sh** - Get operating frequency (MHz)
- **wlNoiseFloor.sh** - Get noise floor (dBm)
- **wlRate.sh** - Get TX/RX bitrate statistics
- **wlSNR.sh** - Get Signal-to-Noise ratio
- **lm-sensors-pass.sh** - LM-SENSORS-MIB thermal sensor pass script
- **distro.sh** - Extract clean OpenWrt version string
- **snmpd-config-generator.sh** - Auto-generate UCI config

### Configuration Files
- **snmpd-base-config** - Base UCI configuration template

### Utility Scripts
- **setup-snmpd.sh** - Automated installation script
- **cleanup-and-fix.sh** - Remove old broken exec entries

### Documentation
- **README.md** - Complete setup and usage guide
- This **DEPLOYMENT-GUIDE.md** - Installation and usage guide

## Quick Deployment

### 1. Upload to OpenWrt Device
```bash
# Create a deployment tarball
tar czf openwrt-snmpd-monitoring.tar.gz \
  wl*.sh \
  lm-sensors-pass.sh \
  distro.sh \
  cleanup-and-fix.sh \
  snmpd-config-generator.sh \
  setup-snmpd.sh \
  snmpd-base-config

# Upload to device
scp openwrt-snmpd-monitoring.tar.gz root@your-device:/tmp/

# Extract and run setup
ssh root@your-device
cd /tmp
tar xzf openwrt-snmpd-monitoring.tar.gz
chmod +x setup-snmpd.sh
./setup-snmpd.sh
```

### 2. Cleanup Old Config (If Upgrading)
```bash
# SSH to device
ssh root@your-device

# Run cleanup to remove old exec entries
/etc/librenms/cleanup-and-fix.sh

# Verify thermal sensors work
snmpwalk -v2c -c public localhost LM-SENSORS-MIB::lmTempSensorsValue
```

### 3. Verify from Monitoring Server
```bash
# Check wireless metrics
snmpwalk -v2c -c public localhost .1.3.6.1.4.1.8072.1.3.2 | grep -E 'clients|frequency|snr'

# Check thermal sensors (should show Gauge32, not "Wrong Type")
snmpwalk -v2c -c public localhost LM-SENSORS-MIB::lmTempSensorsValue
```

### 4. LibreNMS Discovery
Thermal sensors will be auto-discovered by LibreNMS since they're at standard LM-SENSORS-MIB OIDs.

## Key Improvements in Final Version

1. ✅ **LM-SENSORS-MIB via pass** - Proper standard MIB, correct data types
2. ✅ **No "Wrong Type" errors** - Gauge32, INTEGER, STRING all correct
3. ✅ **Supports unlimited thermal zones** - Not limited to 0-9
4. ✅ **Auto-discovery in LibreNMS** - No custom PHP scripts needed
5. ✅ **Clean distro detection** - Returns "OpenWrt X.X.X" without leading spaces
6. ✅ **Automatic cleanup** - cleanup-and-fix.sh removes old broken entries

## Summary

This package provides:
- Complete wireless monitoring (clients, frequency, rates, SNR, noise)
- Proper thermal sensor monitoring via LM-SENSORS-MIB
- Auto-configuration generation
- Works on all OpenWrt devices (ap1, ap2, risc-ap tested)
- Standard SNMP MIBs for maximum compatibility
