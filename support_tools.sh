#stop all ratholes service
for s in `sudo systemctl list-units --type=service --no-pager | grep ratholes | cut -d '.' -f 1`; do sudo systemctl stop $s; done
