#!/bin/bash
# Setting up variables needed
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)

# Checking if there is sudo permission
if [[ $EUID > 0 ]]
  then echo "Please run as root"
  exit
fi
	

#: Installing programs
# Updating all packages
sudo DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y -qq wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Librewolf
sudo apt update && sudo apt install -y wget gnupg lsb-release apt-transport-https ca-certificates
distro=$(if echo " una bookworm vanessa focal jammy bullseye vera uma " | grep -q " $(lsb_release -sc) "; then lsb_release -sc; else echo focal; fi)
wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
sudo tee /etc/apt/sources.list.d/librewolf.sources << EOF > /dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF
sudo apt-get -qq update && sudo apt-get -qq upgrade -y

# Nala
sudo apt-get install -y nala

# Other packages
sudo nala install -y unzip net-tools neofetch kitty librewolf htop autojump gimp code
wget https://starship.rs/install.sh
sudo chmod +x install.sh
$SCRIPT_DIR/install.sh -y

# .net
wget https://dot.net/v1/dotnet-install.sh -O $SCRIPT_DIR/dotnet-install.sh
chmod +x ./dotnet-install.sh
$SCRIPT_DIR/dotnet-install.sh --version latest
$SCRIPT_DIR/dotnet-install.sh --channel 7.0
$SCRIPT_DIR/dotnet-install.sh --channel 6.0


#: Download font
# https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip 
FONT_LINK=https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
echo "Setting up the font..."
echo " - Downloading latest JetBrainsMono NerdFont"
wget $FONT_LINK
echo " - Unzipping font"
unzip -qq JetBrainsMono.zip -d JetBrainsMono
# Moving files to most common font folder
echo " - Moving the font to the most common font folder"
sudo mkdir /usr/share/fonts/JetBrainsMono
sudo mv $SCRIPT_DIR/JetBrainsMono/*.ttf /usr/share/fonts/JetBrainsMono/
# Regenerate the font cache
sudo fc-cache -f
echo "Font is now ready."

#: Applying configs
# Kitty
mkdir $USER_HOME/.config/kitty
cp $SCRIPT_DIR/kitty.conf $USER_HOME/.config/kitty/kitty.conf
cp $SCRIPT_DIR/KeyBindingsKitty /usr/local/bin/KeyBindingsKitty
sudo chmod +x $USER_HOME/.config/kitty/KeyBindingsKitty

# Starship
cp $SCRIPT_DIR/starship.toml $USER_HOME/.config/starship.toml
echo 'eval "$(starship init bash)"' >> $USER_HOME/.bashrc

# Git
git config --global init.defaultBranch main
git config --global user.name "ConfuzzedCat"
git config --global user.email confuzzedcat@gmail.com

# Privacy stuff
sudo chmod +x $SCRIPT_DIR/privacy-script.sh
$SCRIPT_DIR/privacy-script.sh

# Cleanup
sudo DEBIAN_FRONTEND=dialog
rm $SCRIPT_DIR/install.sh
rm $SCRIPT_DIR/dotnet-install.sh
