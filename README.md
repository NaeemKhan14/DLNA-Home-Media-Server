# Introduction
This project creates a DLNA server on Raspberry Pi through which any DLNA capable device - such as a smart TV - can stream media through. It uses a torrent client to download video files directly to an external drive connected to Raspberry Pi. It is capable of downloading files while media is begin streamed on a single device, and users can manage their data using the provided web interface to delete uncessary files.

# Requirements
- Raspberry Pi 3 or newer.
- Rasbian Lite (the program has been tested on headless version of Raspbian only).
- A USB flash drive (NTFS Formatted).
- Wired connection through ethernet is recommended.

# Prerequisites
- Make sure you have Raspbian Lite installed and SSH enabled on it. [Here is a good tutorial](https://randomnerdtutorials.com/installing-raspbian-lite-enabling-and-connecting-with-ssh/) if you are new to this.
- For the initial setup, an external drive must be connected to one of the USB ports on your Raspberry Pi **before** you power it on. Make sure the external drive is NTFS formatted.
- (Optional) Assign a static IP for your Raspberry Pi through your router.
- Download Putty from [here](https://the.earth.li/~sgtatham/putty/latest/w32/putty.exe) for SSH connection to your Raspberry Pi.

# Installation
- Login to your Raspberry Pi using Putty and clone the repository on it.
- Or write the following commands in terminal in sequence:

```
wget https://github.com/NaeemKhan14/DLNA-Home-Media-Server/archive/refs/heads/main.zip
sudo apt install -y unzip
unzip main.zip
```

- This should give you the `DLNA-Home-Media-Server-main` folder. Navigate into it using:

`cd DLNA-Home-Media-Server-main`

- Now execute the following commands:

```
sudo chmod 777 setup.sh
./setup.sh
```

- The setup should take a while, but once it is completed, everything should be installed. You can connect to the torrent web client using your brower and http://piIPaddress:8080 and the management panel at http://piIPaddress/. To find out the piIPaddress, write `hostname -I` in the Raspberry Pi's terminal to get the IP address assigned to it.

- Login to torrent web client at http://piIPaddress:8080. The default credentials are:
username: admin
password: adminadmin
- Once logged in, go to Tools -> Options. Under the Downloads tab, change the `Default Save Path` to `/media/hdd/videos`.
