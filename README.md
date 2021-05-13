# Requirements
- Raspberry Pi 3 or newer.
- Rasbian Lite (the program has been tested on headless version of Raspbian only).
- A USB flash drive (NTFS Formatted).

# Prerequisites
- Make sure you have Raspbian Lite installed and SSH enabled on it. [Here is a good tutorial](https://randomnerdtutorials.com/installing-raspbian-lite-enabling-and-connecting-with-ssh/) if you are new to this.
- For the initial setup, an external drive must be connected to one of the USB ports on your Raspberry Pi **before** you power it on.
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

- The setup should take a while, but once it is completed, everything should be installed.
