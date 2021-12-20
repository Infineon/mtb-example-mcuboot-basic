################################################################################
# \file Makefile
# \version 1.0
#
# \brief
# Top-level application make file.
#
################################################################################
# \copyright
# Copyright 2020-2021, Cypress Semiconductor Corporation (an Infineon company)
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

################################################################################
# MCUboot Specific Configuration
###############################################################################

# use SWAP_UPGRADE = 0 for overwrite only mode, secondary image is simply
# copied to primary slot after successful validation.
# use SWAP_UPGRADE = 1 for swap upgrade mode
SWAP_UPGRADE ?= 0  

# Set to 1 when MCUboot needs to support external flash for the secondary slot.
# Default location is internal flash.
USE_EXT_FLASH ?= 0

# Use hardware accelerated Crypto for MbedTLS
USE_CRYPTO_HW ?= 1

################################################################################
# Basic Configuration
################################################################################

# Target board/hardware (BSP).
# To change the target, it is recommended to use the Library manager 
# ('make modlibs' from command line), which will also update Eclipse IDE launch 
# configurations. If TARGET is manually edited, ensure TARGET_<BSP>.mtb with a 
# valid URL exists in the application, run 'make getlibs' to fetch BSP contents
# and update or regenerate launch configurations for your IDE.
TARGET=CY8CPROTO-062-4343W

# Name of application (used to derive name of final linked file).
APPNAME=mtb-example-psoc6-mcuboot-basic-bootloader

# Name of toolchain to use. Options include:
#
# GCC_ARM -- GCC provided with ModusToolbox IDE
# ARM     -- ARM Compiler (must be installed separately)
# IAR     -- IAR Compiler (must be installed separately)
#
# See also: CY_COMPILER_PATH below
TOOLCHAIN=GCC_ARM

# CPU to target; CM4 is the default CPU when this variable is not present.
CORE=CM0P

# Default build configuration. Options include:
#
# Debug -- build with minimal optimizations, focus on debugging.
# Release -- build with full optimizations
# Custom -- build with custom configuration, set the optimization flag in CFLAGS

CONFIG=Debug

# If set to "true" or "1", display full command-lines when building.
VERBOSE=


################################################################################
# Advanced Configuration
################################################################################

# Enable optional code that is ordinarily disabled by default.
#
# Available components depend on the specific targeted hardware and firmware
# in use. In general, if you have
#
#    COMPONENTS=foo bar
#
# ... then code in directories named COMPONENT_foo and COMPONENT_bar will be
# added to the build
#

# Do not define PSOC6HAL component as HAL is not supported for CM0+
COMPONENTS=CUSTOM_DESIGN_MODUS

# Like COMPONENTS, but disable optional code that was enabled by default.
DISABLE_COMPONENTS=BSP_DESIGN_MODUS

# By default the build system automatically looks in the Makefile's directory
# tree for source code and builds it. The SOURCES variable can be used to
# manually add source code to the build process from a location not searched
# by default, or otherwise not found by the build system.
SOURCES=

# Like SOURCES, but for include directories. Value should be paths to
# directories (without a leading -I).
INCLUDES=

# Include the application make files 
include ./app.mk
include ./shared_config.mk

# The following defines describe the flash map used by MCUBoot
DEFINES+=CY_BOOT_BOOTLOADER_SIZE=$(BOOTLOADER_APP_FLASH_SIZE) \
         CY_BOOT_PRIMARY_1_SIZE=$(MCUBOOT_SLOT_SIZE) \
         CY_BOOT_SECONDARY_1_SIZE=$(MCUBOOT_SLOT_SIZE) \
         CY_BOOT_SCRATCH_SIZE=$(MCUBOOT_SCRATCH_SIZE)

# Add additional defines to the build process (without a leading -D).
DEFINES+=PSOC_064_512K \
         MBEDTLS_CONFIG_FILE='"mcuboot_crypto_config.h"' \
         ECC256_KEY_FILE='"$(SIGN_KEY_FILE).pub"' \
         MCUBOOT_IMAGE_NUMBER=$(MCUBOOT_IMAGE_NUMBER) \
         MCUBOOT_MAX_IMG_SECTORS=$(MCUBOOT_MAX_IMG_SECTORS)

ifeq ($(SWAP_UPGRADE), 0)
DEFINES+=MCUBOOT_OVERWRITE_ONLY
endif

ifeq ($(USE_EXT_FLASH), 1)
DEFINES+=CY_ENABLE_XIP_PROGRAM
DEFINES+=CY_BOOT_USE_EXTERNAL_FLASH
endif

ifeq ($(USE_CRYPTO_HW), 1)
CY_MBEDTLS_ACCLERATION_LIB_PATH=$(MCUBOOT_CY_PATH)/libs/cy-mbedtls-acceleration/mbedtls_MXCRYPTO

DEFINES+=CY_CRYPTO_HAL_DISABLE MBEDTLS_USER_CONFIG_FILE='"mcuboot_crypto_acc_config.h"'
SOURCES+=$(wildcard $(CY_MBEDTLS_ACCLERATION_LIB_PATH)/*.c)
INCLUDES+=$(CY_MBEDTLS_ACCLERATION_LIB_PATH)
endif

# Select softfp or hardfp floating point. Default is softfp.
VFP_SELECT=hardfp

# Additional / custom C compiler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
CFLAGS=

# Additional / custom C++ compiler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
CXXFLAGS=

# Additional / custom assembler flags.
#
# NOTE: Includes and defines should use the INCLUDES and DEFINES variable
# above.
ASFLAGS=

# Additional / custom linker flags.
LDFLAGS=

# Additional / custom libraries to link in to the application.
LDLIBS=

# Custom pre-build commands to run.
# MCUboot uses submodules and "make getlibs" currently does not support
# fetching submodules.
# The PREBUILD command fetches the submodules only if the content of the 
# "mcuboot/ext/mbedtls" directory is empty. 
#
# QSPI memory configuration files (cycfg_qspi_memslot.c/.h) are not
# auto-generated since QSPI is not enabled by default in design.modus. 
# The second pre-build step invokes the QSPI Configurator tool to generate the
# files from design.cyqspi file, under GeneratedSource directory. This
# configuration is used by the programmer to program the external flash. 
# See cy_serial_flash_prog.c file for details. 
PREBUILD_VAR=\
@if [ -n "$$(ls -A $(MBEDTLS_PATH) 2>/dev/null)" ]; then\
    echo "Git submodules for MCUboot exist. Skipping this step...";\
    else\
    echo "Initializing Git Submodules for MCUboot";\
    cd libs/mcuboot;git submodule update --init --recursive;\
fi;\
if [ $(USE_EXT_FLASH) -eq 1 ]; then\
    $(CY_QSPI_CONFIGURATOR_DIR)/qspi-configurator-cli --config $(wildcard ./COMPONENT_CUSTOM_DESIGN_MODUS/TARGET_$(TARGET)/*.cyqspi);\
fi;

PREBUILD= $(PREBUILD_VAR)

# Custom post-build commands to run.
POSTBUILD=

# Toolchain specific linker flags
ifeq ($(TOOLCHAIN), GCC_ARM)
LINKER_SCRIPT=$(wildcard ./linker_script/TARGET_$(TARGET)/TOOLCHAIN_$(TOOLCHAIN)/*.ld)
LDFLAGS+=-Wl,--defsym=CM0P_FLASH_SIZE=$(BOOTLOADER_APP_FLASH_SIZE),--defsym=CM0P_RAM_SIZE=$(BOOTLOADER_APP_RAM_SIZE)
else
$(error Only GCC_ARM is supported at this moment)
endif

################################################################################
# Paths
################################################################################

# Relative path to the project directory (default is the Makefile's directory).
#
# This controls where automatic source code discovery looks for code.
CY_APP_PATH=

# Relative path to the shared repo location.
#
# All .mtb files have the format, <URI>#<COMMIT>#<LOCATION>. If the <LOCATION> field 
# begins with $$ASSET_REPO$$, then the repo is deposited in the path specified by 
# the CY_GETLIBS_SHARED_PATH variable. The default location is one directory level 
# above the current app directory.
# This is used with CY_GETLIBS_SHARED_NAME variable, which specifies the directory name.
CY_GETLIBS_SHARED_PATH=../../

# Directory name of the shared repo location.
#
CY_GETLIBS_SHARED_NAME=mtb_shared

# Absolute path to the compiler's "bin" directory.
#
# The default depends on the selected TOOLCHAIN (GCC_ARM uses the ModusToolbox
# IDE provided compiler by default).
CY_COMPILER_PATH=


# Locate ModusToolbox IDE helper tools folders in default installation
# locations for Windows, Linux, and macOS.
CY_WIN_HOME=$(subst \,/,$(USERPROFILE))
CY_TOOLS_PATHS ?= $(wildcard \
    $(CY_WIN_HOME)/ModusToolbox/tools_* \
    $(HOME)/ModusToolbox/tools_* \
    /Applications/ModusToolbox/tools_*)

# If you install ModusToolbox IDE in a custom location, add the path to its
# "tools_X.Y" folder (where X and Y are the version number of the tools
# folder). Make sure you use forward slashes.
CY_TOOLS_PATHS+=

# Default to the newest installed tools folder, or the users override (if it's
# found).
CY_TOOLS_DIR=$(lastword $(sort $(wildcard $(CY_TOOLS_PATHS))))

ifeq ($(CY_TOOLS_DIR),)
$(error Unable to find any of the available CY_TOOLS_PATHS -- $(CY_TOOLS_PATHS). On Windows, use forward slashes.)
endif

$(info Tools Directory: $(CY_TOOLS_DIR))

include $(CY_TOOLS_DIR)/make/start.mk
