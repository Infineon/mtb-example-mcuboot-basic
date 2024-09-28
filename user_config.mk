################################################################################
# \file user_config.mk
# \version 1.0
#
# \brief
# Holds configuration and error checking the Bootloader
# and Blinky apps.
#
################################################################################
# \copyright
# Copyright 2020-2024, Cypress Semiconductor Corporation (an Infineon company)
# SPDX-License-Identifier: Apache-2.0
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

# Include the common make file
include ../common.mk

################################################################################
# Shared Configuration
################################################################################

# Device family name
# E.g. FAMILY=PSOC6, FAMILY=XMC7000
ifneq ($(filter $(TARGET), APP_KIT_XMC72_EVK APP_KIT_XMC72_EVK_MUR_43439M2 APP_KIT_XMC71_EVK_LITE_V1),)
FAMILY=XMC7000
else
FAMILY=PSOC6
endif

# Device platform name
# E.g. PLATFORM=PSOC_062_512K, PLATFORM=PSOC_062_1M, PLATFORM=PSOC_062_2M, PLATFORM=XMC7200, PLATFORM=XMC7100
PLATFORM=$(if $(filter PSOC6_02,$(DEVICE_COMPONENTS)),PSOC_062_2M,$(if $(filter PSOC6_03,$(DEVICE_COMPONENTS)),PSOC_062_512K,$(if $(filter PSOC6_01,$(DEVICE_COMPONENTS)),PSOC_062_1M,$(if $(filter CAT1C8M,$(DEVICE_COMPONENTS)),XMC7200,$(if $(filter CAT1C4M,$(DEVICE_COMPONENTS)),XMC7100)))))

# Flashmap JSON file name
ifeq ($(FAMILY), PSOC6)
FLASH_MAP?=psoc62_overwrite_single.json
else ifeq ($(FAMILY), XMC7000)
FLASH_MAP?=xmc7000_overwrite_single.json
# XMC7000 devices platform configuration
# E.g. xmc7200_platform.json for XMC7200 device, Ex: xmc7100_platform.json for XMC7100 device
ifneq ($(filter $(TARGET), APP_KIT_XMC71_EVK_LITE_V1),)
PLATFORM_CONFIG=xmc7100_platform.json
else
PLATFORM_CONFIG=xmc7200_platform.json
endif
endif

# User app core
# E.g. APP_CORE=CM4, APP_CORE=CM7
ifeq ($(FAMILY), PSOC6)
USER_APP_CORE=CM4
else ifeq ($(FAMILY), XMC7000)
USER_APP_CORE=CM7
endif

# Application core ID
# E.g. For PSOC6 devices, flag value should be "0" always. APP_CORE_ID=0 for user app run by CM4_0 core.
# E.g. For XMC7200 devices, APP_CORE_ID=0 for user app run by CM7_0 core, APP_CORE_ID=1 for user app run by CM7_1 core
# Changing the below flag only applicable for XMC7200 device.
ifeq ($(FAMILY), PSOC6)
USER_APP_CORE_ID=0
else ifeq ($(FAMILY), XMC7000)
USER_APP_CORE_ID?=0
endif

# Name of the key file, used in two places.
# 1. #included in keys.c for embedding it in the Bootloader app, used for image
#    authentication.
# 2. Passed as a parameter to the parameter to the imgtool or cysecuretools for signing the image
#    in the user app Makefile. The path of this key file is set in the user
#    app Makefile.
SIGN_KEY_FILE=cypress-test-ec-p256

# Path of the key file passed as a parameter to the imgtool or cysecuretools for
# signing the image. Name of the key file is set in shared_config.mk
# as a common parameter to both the Bootloader app and Blinky app.
SIGN_KEY_FILE_PATH=../keys

# Flash and RAM size for MCUBoot Bootloader app run by CM0+
BOOTLOADER_APP_RAM_SIZE=0x20000

# MCUBoot header size
# Must be a multiple of 1024 because of the following reason.
# CM4 or CM7 image starts right after the header and the CM4 or CM7 image begins with the
# interrupt vector table. The starting address of the table must be 1024-bytes
# aligned. See README.md for details.
# Number of bytes to be aligned to = Number of interrupt vectors x 4 bytes.
# (1024 = 256 x 4)
#
# Header size is used in two places.
# 1. The location of CM4 or CM7 image is offset by the header size from the ORIGIN
# value specified in the linker script.
# 2. Passed to the imgtool while signing the image. The imgtool fills the space
# of this size with zeroes and then adds the actual header from the beginning of
# the image.
MCUBOOT_HEADER_SIZE=0x400

# Default upgrade method
PLATFORM_DEFAULT_USE_OVERWRITE=0

# Default memory single chunk size
PLATFORM_CHUNK_SIZE=0x200

# Minimum erase size of underlying memory hardware
PLATFORM_MEMORY_ALIGN=0x200

ifeq ($(FAMILY), PSOC6)
# Maximum trailer page size for PSoC6 devices
PLATFORM_MAX_TRAILER_PAGE_SIZE=0x200
else ifeq ($(FAMILY), XMC7000)
# Maximum trailer page size for XMC7000 devices
PLATFORM_MAX_TRAILER_PAGE_SIZE=0x8000
endif

# Encrypted image support
# This code example not supported the encrypted image at the moment
ENC_IMG=0

ifneq ($(ENC_IMG), 0)
$(error This code example not supported the encrypted image at the moment)
endif

################################################################################
# Bootloader App Configuration
################################################################################

# Downgrade prevention, to avoid older firmware version for upgrade
USE_SW_DOWNGRADE_PREV?=1

# When set to `1` and Swap mode is enabled, the application in the secondary slot will overwrite the primary slot if the primary slot application is invalid.
USE_BOOTSTRAP?=1

################################################################################
# Blinky App Configuration
################################################################################

# image type can be BOOT or UPGRADE
IMG_TYPES:=BOOT UPGRADE

# Supported values: BOOT, UPGRADE
# The Blinky app defines the LED period differently depending on whether the
# image is BOOT or UPGRADE.
# BOOT: Use when image is built for the primary slot.
#       --pad argument is not passed to the imgtool or cysecuretools.
# UPGRADE: Use when image is built for secondary slot.
#          --pad argument is passed to the imgtool or cysecuretools.
IMG_TYPE?=BOOT

ifneq ($(filter $(IMG_TYPE), $(IMG_TYPES)),)
else
$(error Set IMG_TYPE to be either BOOT or UPGRADE)
endif

# Image ID
# Below flag value should correspond to the `application_#` number of JSON flash map file used for the build
IMG_ID=1

ifneq ($(IMG_ID), 1)
$(error This code example not supported the multi-image configuration at the moment)
endif
