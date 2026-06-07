#!/bin/bash

echo ""
echo "########################################################################"
echo "#                                                                      #"
echo "#                                                                      #"
echo "#   All credit to, and scripts below from                              #"
echo "#   https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream  #"
echo "#   with minor modifications made to suit UCG-Ultra                    #"
echo "#                                                                      #"
echo "########################################################################"
echo ""
echo "         // Proceeding in 5 seconds..."
echo ""

sleep 5

# Performs actions from Step 1 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream

echo "(1/7) Downloading Blocky..."

mkdir -p /data/blocky/logs
cd /data/blocky
curl -LO https://github.com/0xERR0R/blocky/releases/download/v0.28.2/blocky_v0.28.2_Linux_arm64.tar.gz
tar -xzf blocky_v0.28.2_Linux_arm64.tar.gz
rm blocky_v0.28.2_Linux_arm64.tar.gz
./blocky version

echo "         // Step 1 Complete..."
echo "         // Proceeding in 5 seconds..."
sleep 5

# Performs actions from Step 2 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream
# Modifies the script to use 1.1.1.1 DNS server 
# Removes customDNS mapping (due to inability to customize remote script)
# Sets default blocklist to OISD Big blocklist (https://big.oisd.nl/domainswild)


echo "(2/7) Installing Blocky..."

cat > /data/blocky/config.yml << 'EOF'
connectIPVersion: v4

bootstrapDns:
  - 1.1.1.1
  - 8.8.8.8

upstreams:
  init:
    strategy: fast
  groups:
    default:
      - 1.1.1.1
      - 8.8.8.8
  strategy: parallel_best
  timeout: 50ms

caching:
  minTime: 4h
  maxTime: 72h
  maxItemsCount: 500000
  cacheTimeNegative: 10m
  prefetching: true
  prefetchExpires: 12h
  prefetchThreshold: 1
  prefetchMaxItemsCount: 100000

blocking:
  denylists:
    ads:
      - https://big.oisd.nl/domainswild

  clientGroupsBlock:
    default:
      - ads
  loading:
    refreshPeriod: 6h
    downloads:
      timeout: 10s
      attempts: 3
      cooldown: 1s
    concurrency: 64
    strategy: fast
    maxErrorsPerSource: 5
  blockType: zeroIp
  blockTTL: 1h

filtering:
  queryTypes:
    - AAAA

ports:
  dns: 5335
  http: 4000

ede:
  enable: true

prometheus:
  enable: true
  path: /metrics

queryLog:
  type: csv
  target: /data/blocky/logs
  logRetentionDays: 7
  flushInterval: 30s
  fields:
    - clientIP
    - clientName
    - question
    - responseReason
    - responseAnswer
    - duration

specialUseDomains:
  rfc6762-appendixG: true
EOF




echo "         // Step 2 Complete..."
echo "         // Proceeding in 5 seconds..."
sleep 5

# Performs actions from Step 3 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream


echo "(3/7) Creating Service..."


cat > /etc/systemd/system/blocky.service << 'EOF'
[Unit]
Description=Blocky DNS
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/data/blocky
ExecStartPre=/bin/sleep 5
ExecStart=/data/blocky/blocky --config /data/blocky/config.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


echo "         // Step 3 Complete..."
echo "         // Proceeding in 5 seconds..."
sleep 5

# Performs actions from Step 4 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream


echo "(4/7) Configuring dnsmasq..."

mkdir -p /run/dnsmasq.dhcp.conf.d
cat > /run/dnsmasq.dhcp.conf.d/blocky.conf << 'EOF'
server=127.0.0.1#5335
no-resolv
EOF

killall dnsmasq


# Performs actions from Step 5 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream
# Using code from https://github.com/unifi-utilities/unifi-common/blob/main/remote_install.sh


echo "(5/7) Installing OnBoot..."




#!/usr/bin/env sh

# UniFi Data Directory
DATA_DIR="/data"

# A change in the name udm-boot would need to be reflected as well in systemctl calls.
SYSTEMCTL_PATH="/etc/systemd/system/udm-boot.service"
SYMLINK_SYSTEMCTL="/etc/systemd/system/multi-user.target.wants/udm-boot.service"
SERVICE_META_URL="https://raw.githubusercontent.com/unifi-utilities/unifi-common/HEAD/udm-boot.service"

# --- Functions ---

header() {
  cat <<EOF
  ___         ___            _
 / _ \  _ _  | _ ) ___  ___ | |_
| (_) || ' \ | _ \/ _ \/ _ \|  _|
 \___/ |_||_||___/\___/\___/ \__|

 Execute any script when your system
 starts.

EOF
}

command_exists() {
  command -v "${1:-}" >/dev/null 2>&1
}

depends_on() {
  ! command_exists "${1:-}" && echo "Missing dependency: \`$*\`" 1>&2 && exit 1
}

udm_model() {
  case "$(ubnt-device-info model || true)" in
  "Enterprise Fortress Gateway")
    echo "udment"
    ;;
  "UniFi Cloud Gateway Fiber")
    echo "ucgfiber"
    ;;
  "UniFi Cloud Gateway Max")
    echo "uxgmax"
    ;;
  "UniFi Cloud Gateway Ultra")
    echo "ucgult"
    ;;
  "UniFi Dream Machine")
    echo "udm"
    ;;
  "UniFi Dream Machine Beast")
    echo "udmbeast"
    ;;
  "UniFi Dream Machine Pro")
    echo "udmpro"
    ;;
  "UniFi Dream Machine Pro Max")
    echo "udmpromax"
    ;;
  "UniFi Dream Machine SE")
    echo "udmse"
    ;;
  "UniFi Dream Router")
    echo "udr"
    ;;
  "UniFi Dream Router 7")
    echo "udr7"
    ;;
  "UniFi Dream Wall")
    echo "udw"
    ;;
  "UniFi Express")
    echo "ux"
    ;;
  "UniFi Express 7")
    echo "ux7"
    ;;
  "UniFi NeXt-Gen Gateway Fiber")
    echo "uxgfiber"
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

# download_on_path <path> <url>
download_on_path() {
  [ $# -lt 2 ] &&
    echo "Missing arguments: \`$*\`" 1>&2 &&
    return 1

  curl -sLJo "$1" "$2"

  [ -r "$1" ]
}

install_on_boot_udr_se() {
  systemctl disable udm-boot 2>/dev/null || true
  systemctl daemon-reload
  rm -f "$SYMLINK_SYSTEMCTL"

  echo "Creating systemctl service file"

  if ! download_on_path  "$SYSTEMCTL_PATH" "$SERVICE_META_URL"; then
    echo
    echo "Failed to download on-boot script service" 1>&2
    exit 1
  fi
  sleep 1s

  echo "Enabling UDM boot..."
  systemctl daemon-reload
  systemctl enable "udm-boot"
  systemctl start "udm-boot"

  [ -e "$SYMLINK_SYSTEMCTL" ]
}
header

depends_on ubnt-device-info
depends_on curl

ON_BOOT_D_PATH="${DATA_DIR}/on_boot.d"

case "$(udm_model)" in
udment | ucgfiber | uxgmax | ucgult | udm | udmbeast | udmpro | udmpromax | udmse | udr | udr7 | udw | ux | ux7 | uxgfiber)
  echo "$(ubnt-device-info model) version $(ubnt-device-info firmware) was detected"
  echo "Installing on-boot script..."
  depends_on systemctl

  if ! install_on_boot_udr_se; then
    echo
    echo "Failed to install on-boot script service" 1>&2
    exit 1
  fi

  echo "UDM Boot Script installed"
  ;;
*)
  echo "Unsupported model: $(ubnt-device-info model)" 1>&2
  exit 1
  ;;
esac
echo

echo "On boot script installation finished"
echo
echo "You can now place your scripts in \`${ON_BOOT_D_PATH}\`"
echo


# Performs actions from Step 5 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream



echo "(6/7) Creating Boot Script..."


cat > /data/on_boot.d/10-blocky-dns.sh << 'EOF'
#!/bin/bash

# Wait for dnsmasq to fully initialize
sleep 30

mkdir -p /run/dnsmasq.dhcp.conf.d
cat > /run/dnsmasq.dhcp.conf.d/blocky.conf << 'DNSCONF'
server=127.0.0.1#5335
no-resolv
DNSCONF

# Restart dnsmasq to pick up config
killall dnsmasq

echo "Blocky DNS configured"
EOF

chmod +x /data/on_boot.d/10-blocky-dns.sh




# Performs actions from Step 6 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream





echo "(7/7) Starting and testing service..."

echo ""
echo "... Reloading Daemon..."
systemctl daemon-reload
echo "... Enabling Blocky..."
systemctl enable blocky
echo "... Starting Blocky..."
systemctl start blocky
echo "... Checking Status..."
systemctl status blocky -l --no-pager

echo ""
echo "(Complete) - Please check data above to ensure successful install"
echo "You should REBOOT your Unifi Controller and then check that Blocky is still working"
echo "Use https://adblock.turtlecute.org/ to test ad blocking"
echo "Closing in 60 seconds..."
sleep 60





