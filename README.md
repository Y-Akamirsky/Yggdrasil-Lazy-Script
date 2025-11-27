# Yggdrasil-Lazy-Script
This simple script allows you to run the yggdrasil.service daemon without starting it with a long systemctl command. An alternative is the 'sudo systemctl enable --now yggdrasil.service' command. However, manual launch is better for my situation and maybe for you.

Install:
```bash
curl -sL https://raw.githubusercontent.com/Y-Akamirsky/Yggdrasil-Lazy-Script/refs/heads/main/install_script.sh | bash
```
Remove:
```bash
ygg-lazy-remove
```
