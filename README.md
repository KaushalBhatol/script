# Scripts

## General

Genrate SSL Certificate [*.local] wildcard for 100 year.

```bash
sudo wget -qO- \
  https://raw.githubusercontent.com/KaushalBhatol/script/refs/heads/main/general/gen_wildcard_local.sh \
  | sudo bash
```

## Ubuntu

Swap Storage 4GB [custom]

```bash
sudo wget -qO- \
https://raw.githubusercontent.com/KaushalBhatol/script/refs/heads/main/ubuntu/add_swap.sh \
| sudo bash 4
```

Change SSH Port 3001 [Custom]

```bash
sudo wget -qO- \
https://raw.githubusercontent.com/KaushalBhatol/script/refs/heads/main/ubuntu/change_ssh_port.sh \
| sudo bash 3001
```

Flush all IP-Tables rules and removing iptable [Oracle Cloud]

```bash
sudo wget -qO- \
https://raw.githubusercontent.com/KaushalBhatol/script/refs/heads/main/ubuntu/flush_all_iptables.sh \
| sudo bash
```

Remove All Snaps and purge Snapd

```bash
sudo wget -qO- \
https://raw.githubusercontent.com/KaushalBhatol/script/refs/heads/main/ubuntu/remove_snapd.sh \
| sudo bash
```
