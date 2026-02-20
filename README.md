### My setup info
- Bootloader: [systemd-boot](https://wiki.archlinux.org/index.php/Systemd-boot) / [EFISTUB](https://wiki.archlinux.org/index.php/EFISTUB)
- WM: [Sway](https://github.com/swaywm/sway)
- Bar: [Waybar](https://github.com/Alexays/Waybar)
- Editor: [Neovim](https://github.com/neovim/neovim)

To clone only neovim configuration use the script from the repo. You can do it like this:
```
sh <(curl -fsSL https://raw.githubusercontent.com/etircopyh/arch.conf/wip/clone-dir.sh) wip dotfiles/user/.config/nvim && cd /tmp/neovim-config/dotfiles/user/.config/nvim
```
- Terminal: [foot](https://codeberg.org/dnkl/foot) / Terminal Font: [Hasklig](https://github.com/i-tu/Hasklig)
- Terminal multiplexer: [Tmux](https://github.com/tmux/tmux)
- Shell: [zsh](https://github.com/zsh-users/zsh) + [grml-zsh-config](https://grml.org/zsh/#grmlzshconfig) (most seamless shell experience ever)
- Sound server: [PipeWire](https://wiki.archlinux.org/title/PipeWire) + [WirePlumber](https://wiki.archlinux.org/title/WirePlumber)
- Browser: [Firefox](https://www.mozilla.org/en-US/firefox) ([My custom FF configuration](https://github.com/etircopyh/fox-hax))
- Video player: [mpv](https://github.com/mpv-player/mpv)
- Image viewer: [imv](https://github.com/eXeC64/imv)
- Screen capture: [Flameshot](https://github.com/flameshot-org/flameshot) + [OBS](https://github.com/obsproject/obs-studio)
- Network: [systemd-networkd](https://github.com/systemd/systemd/tree/master/src/network) + [iwd](https://wiki.archlinux.org/index.php/Iwd) + [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy)
- [Systemd units](./dotfiles/system/usr/lib/systemd/system) (meant to be placed into /usr/lib/systemd/system/)
- Useful scripts

### Extra
- [Firefox Browser tweaks](https://github.com/etircopyh/fox-hax "fox-hax")
- [Fonts](http://ix.io/22cH "Font list")
- [Packages](http://ix.io/22d2)
- [Wallpapers](https://drive.google.com/open?id=1qbPJEeEe5k4p4rwqMqT48-juFqzc-pM1) / [Wallpapers [Archive]](https://drive.google.com/open?id=1_W3DUqlarIlw96iu3r1tqafgNkMdghs8)
- [My DSDT firmware fix (ASUS X54C)](./essentials/asus-x54c-fixed-dsdt)
