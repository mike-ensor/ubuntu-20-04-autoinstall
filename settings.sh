#!/bin/bash

UBUNTU_VERSION="20.04.2"
DISK_0_PATH="/dev/nvme0n1" # Default to NUC disks
DISK_1_PATH="" # default to empty, allows automation to replace when commented out

####################################################
##############  LARGE NUCS   #######################
####################################################

# # Defaults for partitions (bigger 1TB size)
# GRUB_PARTITION="250MB"
# PRIMARY_PARTITION="200GB"
# AUX_PARTITION="750GB"
# ## Disk Drive NUC
# DISK_0_PATH="/dev/nvme0n1"

####################################################
##############  ATOS     ###########################
####################################################

# Defaults for Atos partition (2-disks)
GRUB_PARTITION="250MB"
PRIMARY_PARTITION="800GB"
AUX_PARTITION="800GB"
## Disk drive paths (Atos)
DISK_0_PATH="/dev/sda"
DISK_1_PATH="/dev/sdb"

####################################################
##############  MEDIUM NUCS   ######################
####################################################

# Medium NUC (500GB total)
# GRUB_PARTITION="250MB"
# PRIMARY_PARTITION="130GB"
# AUX_PARTITION="300GB"
## Disk Drive NUC
# DISK_0_PATH="/dev/nvme0n1"

####################################################
##############  SMALL NUCS ( MOST COMMON) ##########
####################################################

# Smaller NUC (250GB total)
# GRUB_PARTITION="250MB"
# PRIMARY_PARTITION="130GB"
# AUX_PARTITION="100GB"
## Disk Drive NUC
# DISK_0_PATH="/dev/nvme0n1"

