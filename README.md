Credit to the following for code:
https://jmcglock.substack.com/p/running-blocky-on-the-unifi-dream
https://github.com/unifi-utilities/unifi-common

Installing Blocky [Local, High-speed ad blocking service] on your Unifi Gateway.

Step 1: Enable SSH in your Unifi Console. Go to your Network Console > Settings > Control Plane > Console > (scroll down) to SSH.  Enable and set a password.

Step 2: Using a program such as Putty, connect to your console's IP address.

Step 3: Login as "root" and use the password as set in step 1 above.

Step 4: Enter the following in the SSH console, followed by the enter key.

curl -fsL "https://github.com/davemalins82-boop/ubiquitous-leap/releases/download/Release/remote_install.sh" | /bin/bash






