#!/bin/sh
######################################################################
# Script Name	 : setup.sh
# Description	 : Script to create and setup a DLNA server for home
#                media server
# Usage        : run ./setup.sh and make sure index.php is in the same
#                directory as setup.sh file. And make sure an external
#                USB drive is connected to one of the USB ports on rpi.
# Author       : Naeem Khan
# Email        : naeemukhan14@gmail.com
######################################################################

# Get the external NTFS drive's UUID.
diskUUID=$(sudo blkid -t TYPE=ntfs -sUUID | cut -d'"' -f2)

if [ -z "$diskUUID" ];
then
        echo "No external drive attached to USB ports."
        echo "Please attach a USB drive and reboot the raspberry pi before running this setup again."
        echo "If you have attached an external USB drive, then make sure it is NTFS formatted."
        echo "The program will now terminate."
        exit 1
fi

if [ ! -f "./index.php" ]
then
        echo "index.php not found. Make sure it is in the same directory where setup.sh is running from."
        echo "The program will now terminate."
        exit 1
fi

## Installing required packages
# Initial setup.
sudo apt-get update && sudo apt-get -y upgrade

# List of packages to be installed.
packages='ntfs-3g apache2 php ufw minidlna qbittorrent-nox'
# Loop through the list of packages and install them if not already installed.
for pkg in $packages; do
        # Query to check if this package is installed.
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $pkg|grep "install ok installed")
        # Announce the status of package.
        echo Checking for $pkg: $PKG_OK
        # If package is not installed, we will install it here.
        if [ "" = "$PKG_OK" ]; then
                echo "No $pkg. Setting up $pkg."
                sudo apt install -y $pkg
                # Set up for ufw package.
                if [ $pkg = 'ufw' ]; then
                        sudo ufw allow OpenSSH
                        sudo ufw allow 'WWW Full'
                        sudo ufw allow 8200
                        sudo ufw allow 8080
                        yes y | sudo ufw enable
                fi
        fi
done

#################
# USB drive setup
#################
# Set up the media directory if not enabled.
if [ ! -d "/media/hdd" ]
then
        sudo mkdir /media/hdd
        echo "Created /media/hdd folder."
else
        echo "Media directory already exist."
fi

# Check if any ntfs drive is already added to the fstab file.
if grep -Fq "ntfs-3g" /etc/fstab
then
        # If a drive is already configured, we remove it before adding this new one.
        echo "Found a drive signature in settings. Removing it now."
        sudo sed -i -e '$ d' /etc/fstab
fi

# Add the drive to FSTAB to be mounted to /media/hdd on start up.
sudo sh -c 'echo "UUID="'$diskUUID'" /media/hdd ntfs-3g big_writes,noatime,nodiratime,defaults,nofail,x-systemd.device-timeout=30,uid=1000,gid=1000,umask=000 0 0" >> /etc/fstab'
echo "Finished setting up drive with UUID "$diskUUID" to be mounted on startup."

################# 
# MiniDLNA config
#################

# Set up directories for minidlna.
if [ ! -d "/media/hdd/videos" ]
then
        echo "creating videos folder"
        sudo mkdir /media/hdd/videos
fi
if [ ! -d "/media/hdd/pictures" ]
then
        echo "creating pictures folder"
        sudo mkdir /media/hdd/pictures
fi
if [ ! -d "/media/hdd/music" ]
then
        echo "creating music folder"
        sudo mkdir /media/hdd/music
fi

# Setup the minidlna config file.
if grep -Fq "friendly_name=MediaServer" /etc/minidlna.conf
then
        echo "Minidlna config seems fine. Ignoring it."
else
        echo "Writing to minidlna config file."
        echo "port=8200
        friendly_name=MediaServer
        media_dir=A,/media/hdd/music
        media_dir=P,/media/hdd/pictures
        media_dir=V,/media/hdd/videos
        album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg
        album_art_names=AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg
        album_art_names=Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg
        log_dir=/var/log/minidlna
        log_level=fatal
        inotify=yes
        max_connections=5" | sudo tee /etc/minidlna.conf
fi

echo "Restarting minidlna service."
sudo systemctl restart minidlna

############################ 
# qBittorrent configuration.
############################

# Add a new user for qBittorrent if doesn't exist.
if id -u "qbittorrent" >/dev/null 2>&1;
then
        echo "qbittorrent user already exist."
else
        sudo useradd -r -m qbittorrent
        sudo usermod -a -G qbittorrent pi
fi

# Create a startup script for qBittorrent.
echo "Creating qBittorent service."
if [ ! -f "/etc/systemd/system/qbittorrent.service" ]; then
        echo "[Unit]
        Description=qBittorrent
        After=network.target

        [Service]
        Type=forking
        User=qbittorrent
        Group=qbittorrent
        UMask=002
        ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080
        Restart=on-failure

        [Install]
        WantedBy=multi-user.target" | sudo tee /etc/systemd/system/qbittorrent.service
else
        echo "qBittorent service already exist. Ignoring it."
fi

# Enable the service.
sudo systemctl enable qbittorrent

# Start the qBittorrent service to accept the terms and conditions.
yes y | qbittorrent-nox &

# Get qBittorrent's PID.
PID=$!
# Wait for 2 seconds.
sleep 2
# Kill it.
kill $PID

sleep 5

echo "Starting qBittorrent service."
sudo systemctl start qbittorrent

######################################
# Setup user management web interface.
######################################

# Remove the default nginx welcome page.
if [ -f "/var/www/html/index.nginx-debian.html" ];
then
        sudo rm /var/www/html/index.nginx-debian.html
        sudo rm /var/www/html/index.html
fi

echo "Copying web interface files to local server's directory."
sudo cp ./index.php /var/www/html

echo "Removing default apache2 files from webserver."
sudo rm /var/www/html/index.html

echo "Setup completed!."
