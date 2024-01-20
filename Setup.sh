#!/bin/bash
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
sudo apt-get -qq update && sudo apt-get -qq upgrade -y

# Nala
sudo apt-get install -y nala

# Other packages
sudo nala install -y --simple unzip net-tools neofetch kitty librewolf htop autojump gimp code
curl -sS https://starship.rs/install.sh | sh

#: Download font
FONT_LINK=https://github.com/ryanoasis/nerd-fonts/releases/download/latest/JetBrainsMono.zip
echo "Setting up the font..."
echo " - Downloading latest JetBrainsMono NerdFont"
wget $FONT_LINK
echo " - Unzipping font"
unzip JetBrainsMono.zip -qq -d JetBrainsMono
# Moving files to most common font folder
echo " - Moving the font to the most common font folder"
sudo mkdir /usr/share/fonts/JetBrainsMono
sudo mv ./JetBrainsMono/*.ttf /usr/share/fonts/JetBrainsMono/
# Regenerate the font cache
sudo fc-cache -f
echo "Font is now ready."

#: Applying configs
# Kitty
mkdir ~/.config/kitty
mv kitty.conf ~/.config/kitty
mv KeyBindingsKitty ~/.config/kitty
sudo chmod +x ~/.config/kitty/KeyBindingsKitty

# Starship
mv starfish.toml ~/.config/
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# Cleanup
sudo DEBIAN_FRONTEND=dialog
