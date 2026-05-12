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

echo "(1/4) Downloading Blocky..."

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
# Modifies the script to use 1.1.1.3 DNS server (includes anti-malware, plus adult filter by default)
# Removes customDNS mapping (due to inability to customize remote script)
# Sets default blocklist to OISD Big blocklist (https://big.oisd.nl/domainswild)
# Whitelists Google Ad Services to ensure search engine and shopping links are not impacted (certain ads will still show as a result)

echo "(2/4) Installing Blocky..."

cat > /data/blocky/config.yml << 'EOF'
connectIPVersion: v4

bootstrapDns:
  - 1.1.1.3
  - 9.9.9.9

upstreams:
  init:
    strategy: fast
  groups:
    default:
      - 1.1.1.3
      - 9.9.9.9
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
  allowlists:
    ads:
      - |
        # inline definition with YAML literal block scalar style
        /googleadservices.com/

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


echo "(3/4) Creating Service..."


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

# Performs actions from Step 3 of https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream


echo "(4/4) Starting and testing service..."

echo.
echo "... Reloading Daemon..."
systemctl daemon-reload
echo "... Enabling Blocky..."
systemctl enable blocky
echo "... Starting Blocky..."
systemctl start blocky
echo "... Checking Status..."
systemctl status blocky

echo.
echo "(Complete) - Please check data above to ensure successful install"
echo "Closing in 30 seconds..."
sleep 30





