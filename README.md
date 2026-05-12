

Step 5: Make It Persist
The /run directory is tmpfs and gets wiped on reboot. Install the unifios-utilities on-boot-script to run a script at startup:

'curl -fsL "https://raw.githubusercontent.com/unifi-utilities/unifi-common/HEAD/remote_install.sh" | /bin/bash'




