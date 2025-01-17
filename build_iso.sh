#!/bin/bash

# Include user-settings
source ./settings.sh

BASE_DIR='iso'
SUB_DIR='nocloud'
REPO_DIR="$BASE_DIR/$SUB_DIR"
UBUNTU_MIRROR="https://mirror.pit.teraswitch.com/ubuntu-releases"
ISO_NAME="ubuntu-$UBUNTU_VERSION-live-server-amd64.iso"

function show_help() {
    echo ""
    echo "Usage:"
    echo "  ./build_iso.sh [options]"
    echo "  Options:"
    echo "    -h [-?]                   Show this help text"
    echo "    -u <username>             Use this username at install time"
    echo "    -P                        Prompt for password to use at install time"
    echo "    -F </dev/sdX>             Flash ISO to USB"
    echo "    -K <github_handle>        Pull SSH keys from github"
    echo "    -H <hostname>             The hostname to be set at install time"
    echo ""
}


function install_packages() {
    if [ ! -f ./.apt_updated ]; then
        sudo apt update -y && \
        sudo apt install syslinux-utils genisoimage p7zip-full xorriso wget isolinux -y && \
        touch ./.apt_updated
    fi
}


function download_iso() {
    if [ ! -f $ISO_NAME ]; then
        wget $UBUNTU_MIRROR/$UBUNTU_VERSION/$ISO_NAME
    fi
}


function inject_keys() {
    ssh_keys=$'\\n'
    while read key; do
        ssh_keys="$ssh_keys      - '$key'"$'\\n'
    done <pub_keys
    sed -i "s|__REPLACE_ME__|$ssh_keys|g" $REPO_DIR/user-data
}


function build_iso() {
    rm -rf $BASE_DIR
    mkdir -p $BASE_DIR
    7z x $ISO_NAME -x'![BOOT]' -o$BASE_DIR
    cp -r $SUB_DIR $BASE_DIR/
    md5sum $BASE_DIR/README.diskdefines > $BASE_DIR/md5sum.txt
    sed -i "s|---|autoinstall ds=nocloud;s=/cdrom/$SUB_DIR/ ---|g" $BASE_DIR/isolinux/txt.cfg
    sed -i "s|---|autoinstall ds=nocloud\\\;s=/cdrom/$SUB_DIR/ ---|g" $BASE_DIR/boot/grub/grub.cfg
    if [ -f pub_keys ]; then
        inject_keys
    else
        sed -i '/authorized-keys: __REPLACE_ME__/d' $REPO_DIR/user-data
    fi
    sed -i "s|__USER_NAME__|$1|g" $REPO_DIR/user-data
    sed -i "s|__PASSWORD__|$2|g" $REPO_DIR/user-data
    sed -i "s|__HOSTNAME__|$3|g" $REPO_DIR/user-data
    sed -i "s|__GRUB_PARTITION__|${GRUB_PARTITION}|g" $REPO_DIR/user-data
    sed -i "s|__PRIMARY_PARTITION__|${PRIMARY_PARTITION}|g" $REPO_DIR/user-data
    sed -i "s|__AUX_PARTITION__|${AUX_PARTITION}|g" $REPO_DIR/user-data

    xorriso -as mkisofs -r \
        -V Ubuntu\ custom\ amd64 \
        -o ubuntu-$UBUNTU_VERSION-live-server-amd64-autoinstall.iso \
        -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
        -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
        -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
        $BASE_DIR/boot $BASE_DIR
}


function flash_to_usb() {
    echo "Writing ISO to USB at $1. This can take around five minutes to complete..."
    sudo dd if=ubuntu-$UBUNTU_VERSION-live-server-amd64-autoinstall.iso of=$1 bs=1M status=progress
}


function ask_pass() {
    PASSWORD=`openssl passwd -6`
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "Passwords did not match! Exiting..."
        exit 1
    fi
}


function fetch_ssh_keys() {
    curl -Lo pub_keys https://github.com/$1.keys
}

OPTIND=1
USER="abm-admin"
PASSWORD='$6$ODnA9O5uWBDLMzRF$U0Pc7t2vljzCSya2kba/GV.Q1w2uOlitaqtcPZxTZ.d6/RTttjq9rWA9Rp/RlcXLVYSGeJ1..uSMe99mx2yZE/' #troubled-marble-150
USB_DEV=""
GIT_USER=""
HOSTNAME="ubuntu-server" #Default

while getopts "h?u:PF:K:H:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    u)  USER="$OPTARG";;
    P)  ask_pass;;
    F)  USB_DEV="$OPTARG";;
    K)  GIT_USER="$OPTARG";;
    H)  HOSTNAME="$OPTARG";;
    esac
done
shift $(($OPTIND-1))

install_packages
download_iso
if [ ! -z $GIT_USER ]; then
    fetch_ssh_keys "$GIT_USER"
fi
build_iso "$USER" "$PASSWORD" "$HOSTNAME"
if [ ! -z $USB_DEV ]; then
    flash_to_usb "$USB_DEV"
fi
