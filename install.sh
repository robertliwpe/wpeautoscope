#!/bin/bash

echo "Setting Bash Shell"
chsh -s /bin/bash

printf "\r\n\r\n=====================================================================================\r\n\r\n"
printf '\e[1;34m%-6s\e[m' "Welcome to WP Engine's Self Service Scoping Tool! Let's begin..."
printf "\r\n\r\n=====================================================================================\r\n\r\n"
printf "This installation will setup the tool for you, and make sure you have the required dependencies.\r\n\r\n"

printf "\r\nChecking Homebrew...\r\n"

if brew --version | grep -q "command not found"
then
    echo "Homebrew not found. Starting install..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew update
else
    echo "Homebrew is found... Ensuring latest version installed."
    brew update
    brew --version
fi

printf "\r\nChecking Python...\r\n"

if python3 --version | grep -q "command not found"
then
    echo "Python is not found. Starting install..."
    brew install python
    echo 'export PATH="/usr/local/opt/python/libexec/bin:$PATH"' >> ~/.profile
    echo 'export PATH="/usr/local/opt/python/libexec/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="/usr/local/opt/python/libexec/bin:$PATH"' >> ~/.bashrc
    python3 --version
else
    echo "Python found... Ensuring latest version installed."
    brew upgrade python
    python3 --version
fi

printf "\r\nInstalling iTerm2 terminal to execute...\r\n"
brew install --cask iterm2

printf "\r\nInstalling Duti to allow .sh execution...\r\n"
brew install duti
duti -s com.googlecode.iterm2 .sh all

printf "\r\nInstalling File Icon...\r\n"
brew install fileicon

printf "\r\nMaking Application Directory...\r\n"
sleep 1
mkdir -p "/Users/$USER/.wp_engine_autoscope/"
printf "\r\nDone.\r\n"

dirvar=$(dir=$(find ~ -type d -name "*autoscope*" -print -quit 2>/dev/null); echo ${dir//' '/'\ '})

printf "\r\nCopying Files...\r\n"
cp -v "$dirvar"/autoscope.sh "$dirvar"/autoscopeinstalls.sh "$dirvar"/bsphcoreconversion.csv "$dirvar"/writeinstalls.py "$dirvar"/icon.png /Users/$USER/.wp_engine_autoscope/

filelocvar=$(find "/Users/$USER/.wp_engine_autoscope/" -type f -name "autoscope.sh" -print -quit 2>/dev/null)

# printf "\r\n$dirvar\r\n"

printf "Creating executable...\r\n\r\n"

chmod +x "$filelocvar"

printf "Creating symlink shortcut...\r\Origin Application Located: $filelocvar\r\n\r\n"

ln -s "$filelocvar" /Applications/WP\ Engine\ Autoscope\ Tool.app

sleep 3

printf "Creating shortcut in Applications Folder...\r\n\r\n"

fileicon set /Applications/WP\ Engine\ Autoscope\ Tool.app /Users/$USER/.wp_engine_autoscope/icon.png

# echo "# WPE Self Service Scoping Tool" >> ~/.bash_profile
# echo "alias selfscope='$filelocvar'" >> ~/.bash_profile
# echo "# WPE Self Service Scoping Tool" >> ~/.profile
# echo "alias selfscope='$filelocvar'" >> ~/.profile
# echo "# WPE Self Service Scoping Tool" >> ~/.bashrc
# echo "alias selfscope='$filelocvar'" >> ~/.bashrc

printf "Installation DONE! You can now access the Self Service Scoping Tool in the Applications Folder!\r\n\r\n"
# printf "Reload your bash terminal to begin using (if that doesn't work close your current window and open a new one).\r\n"
# printf "Alternatively, you can just DOUBLE CLICK the \"autoscope.sh\" file in the folder.\r\n"

# printf "\r\nNOTE CAREFULLY:\r\n"
# printf "Do NOT change the file structure, keep all files within the same folder.\r\n"
# printf "To use this tool you MUST HAVE OVERDRIVE ACCESS and can IMPERSONATE CUSTOMER ACCOUNTS.\r\n"
# printf "When uninstalling remember to delete or comment out the WPE Self Service Scoping Tool line in your ~/.bash_profile ~/.profile and ~/.bashrc by running \$vi ~/.bash_profile OR \$nano ~/.bash_profile (replacing the appropriate shell profile) and editing...\r\n\r\n"

sleep 10

exit;