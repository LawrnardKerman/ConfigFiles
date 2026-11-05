<table width="100%">
  <tr>
    <td width="50%"><img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/42ba182a-fe2f-45b5-bc59-3becaf945ce5" /></td>
    <td width="50%"><img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ca3c6322-f71a-4f85-a5d0-dfc4e56a3bc6" /></td>
  </tr>
  <tr>
    <td width="50%"><img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c9b1f245-4be0-42f0-adda-460a58f89066" /></td>
    <td width="50%"><img height="1080" alt="image" src="https://github.com/user-attachments/assets/30a67a50-c902-4e2b-9cfe-a96eb9232e26" /></td>

  </tr>
</table>

# ~~Corvid's~~Lawnard's Config
This repo is *my* personal config files based off @TGYT-Dev 's files. Everything is themed after Gruvbox Dark Soft.

## Installing 
For whatever reason you may want to intall these do,
```bash
sudo pacman -S --needed sway kitty mako rofi fish neovim git pipewire wireplumber pipewire-pulse grim slurp swappy starship fzf networkmanager polkit playerctl swaylock fcitx5 cava
git clone https://github.com/LawrnardKerman/ConfigFiles
cd ConfigFiles
chmod +x install.sh
./install.sh
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ../
```
then 
```bash
sudo reboot
```
 ㅤㅤ

> [!NOTE]
> You need yay for this, or any AUR helper but i like yay the best. You can install yay with the below
> ```bash
> git clone https://aur.archlinux.org/yay.git
> cd yay
> makepkg -si
> ```
>
>I'm too lazy to set up the config files for fcitx but this repo is pretty good https://github.com/ayamir/fcitx5-gruvbox
>

## Keybinds

| Shortcut | Action |
|---|---|
| Mod + Return | Open terminal |
| Mod + Shift + Q | Kill focused window |
| Mod + D | App launcher |
| Mod + Shift + D | Run command |
| Mod + Alt + D | Window switcher |
| Mod + Shift + Space | Toggle floating |
| Mod + F | Toggle fullscreen |
| Mod + Shift + C | Reload Sway config |
| Mod + H / J / K / L | Focus left / down / up / right |
| Mod + Shift + H / J / K / L | Move window left / down / up / right |
| Mod + # | Switch to workspace # |
| Mod + Shift + # | Move window to workspace # |
| Mod + Escape | Lock screen |
| Alt + Shift + S | Screenshot region |
