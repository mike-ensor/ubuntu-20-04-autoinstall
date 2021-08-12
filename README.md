# TL;DR

1. Clone this repository
1. Adjust the partition sizes in `settings.sh` to match your machine
    > NOTE: The sizes cannot exceed 100%, best to leave a little un-used than fail during provisioning
1. Ensure you have a USB flashing tool (example: [balena Etcher](https://www.balena.io/etcher/), [Rufus](https://rufus.ie/))
1. (Optional) Create a new SSH key-pair to use with passwordless SSH.
    > NOTE: Having a key **is required**, creating a new key is not.
    ```bash
    # Example ed25519 encryption algorithm key named "nucs" (will create "~/.ssh/nucs" and "~/.ssh/nucs.pub")
    ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/nucs
    ```
1. Copy public key(s) into `pub_keys`
    1. Copy SSH Pub keys into this file (single-line) for passwordless SSH access
    ```bash
    # Add one public key to file
    cat ~/.ssh/nucs.pub >> ./pub_keys
    ```
1. Run the image generator script with opinionated defaults

    ```bash
    # Create 3 ISOs
    ./create-isos.sh -c 3
    ```
1. Use USB flashing tool to flash ISOs to all USBs

## NOTES
* USB does not have a stop method, it reboots after completing. This can re-start the installation process.
* Default username: `abm-admin`
* Default password (though, not used unless necessary): `troubled-marble-150`

---

# Detailed approach

## Build an Ubuntu 20.04 ISO/USB Stick using autoinstall easily!
I've made a pretty simple helper script to build an Ubuntu 20.04 ISO (and even write it to a USB stick if you're building the ISO on the same machine the USB stick is plugged into.) If not... Simply copy the ISO to your local system and use a tool like [balena Etcher](https://www.balena.io/etcher/) to write it to USB.

This script will automatically download the source Ubuntu Server ISO for you. All you need to do is run it! See examples below!

## !!! Booting this USB in any computer will wipe this computer's /dev/nvme0n1 device without asking first !!!
If you have a laptop with a /dev/nvme0n1 this could ruin your laptop if you boot from it... You've been warned!

## !!! This script has only been tested on Ubuntu 20.04 and I've made no attempt to make this work on any other OS !!!

## Defaults:
The default username and password (Unless changed below) are: `ubuntu`

## Example Usage:
### Build a generic ISO
```bash
./build_iso.sh
```
### Build an ISO with custom Password
You will be prompted for a password
```bash
./build_iso.sh -P
```
### Build an ISO with custom Username and Password
Again... you'll be prompted to enter the password
```bash
./build_iso.sh -u myUsername -P
```

### Build an ISO with custom Username and Password and fetch SSH Keys using GitHub handle
Again... you'll be prompted to enter the password
```bash
./build_iso.sh -u myUsername -P -K myGitHubHandle
```

### Build a generic ISO and write it to USB at sdc
```bash
./build_iso.sh -F /dev/sdc
```

### Building a custom ISO and writing it to USB
Again... you'll be prompted to enter the password
```bash
./build_iso.sh -u bestuser -P -F /dev/sdc -K myGitHubHandle
```

### Building a custom ISO with a different hostname
```bash
./build_iso.sh -H my-best-hostname
```

## Adding SSH Keys
To add ssh keys to the iso simply create a file named `pub_keys` in the same directory as `build_iso.sh`

You may have more than one SSH key in this file, just make sure each key is on its own line.

If your SSH key is on GitHub you can use the `-K <myGitHubHandle>` command as well. This will over write the pub_keys file... Currently there is no merge functionallity. Create an issue if you would like to see this feature.


## Reference

### overall
https://ubuntu.com/server/docs/install/autoinstall-reference

### storage
https://curtin.readthedocs.io/en/latest/topics/storage.html
