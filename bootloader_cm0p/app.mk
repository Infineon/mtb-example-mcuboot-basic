################################################################################
# \file app.mk
# \version 1.0
#
# \brief
# Configuration file for adding/removing source files. Modify this file
# to suit the application needs.
#
################################################################################
# \copyright
# Copyright 2020 Cypress Semiconductor Corporation
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

MCUBOOT_PATH=libs/mcuboot

################################################################################
# MBEDTLS Files
################################################################################

MBEDTLS_PATH=$(MCUBOOT_PATH)/ext/mbedtls
CRYPTO_LIB_PATH=$(MBEDTLS_PATH)/crypto/library

# Following files are present in both $(MBEDTLS_PATH)/library and 
# $(MBEDTLS_PATH)/crypto/library. Therefore, use the files only from
# $(MBEDTLS_PATH)/library as mbedtls is the parent project and crypto is a 
# submodule. 
FILES_TO_EXCLUDE=\
    $(CRYPTO_LIB_PATH)/error.c \
    $(CRYPTO_LIB_PATH)/version.c \
    $(CRYPTO_LIB_PATH)/version_features.c

SOURCES+=\
    $(wildcard $(MBEDTLS_PATH)/library/*.c)\
    $(filter-out $(FILES_TO_EXCLUDE), $(wildcard $(CRYPTO_LIB_PATH)/*.c))
        
INCLUDES+=\
    $(MBEDTLS_PATH)/include\
    $(MBEDTLS_PATH)/include/mbedtls\
    $(MBEDTLS_PATH)/crypto/include\
    $(MBEDTLS_PATH)/crypto/include/mbedtls

################################################################################
# MCUboot Files
################################################################################

MCUBOOT_CY_PATH=$(MCUBOOT_PATH)/boot/cypress
MCUBOOTAPP_PATH=$(MCUBOOT_CY_PATH)/MCUBootApp

SOURCES+=\
    $(wildcard $(MCUBOOT_PATH)/boot/bootutil/src/*.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/cy_flash_pal/cy_flash_map.c)\
    $(MCUBOOT_CY_PATH)/platforms/retarget_io_pdl/cy_retarget_io_pdl.c\
    $(MCUBOOTAPP_PATH)/cy_security_cnt.c\
    $(MCUBOOTAPP_PATH)/image_ec256_mbedtls.c\
    $(MCUBOOTAPP_PATH)/keys.c\

# Do not include QSPI API from flash PAL when external flash is not used.
ifeq ($(USE_EXT_FLASH), 1)  
SOURCES+=\
    $(wildcard $(MCUBOOT_CY_PATH)/cy_flash_pal/cy_smif_psoc6.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/cy_flash_pal/flash_qspi/*.c)
endif
    
INCLUDES+=\
    ./keys\
    $(MCUBOOT_PATH)/boot/bootutil/include\
    $(MCUBOOT_PATH)/boot/bootutil/src\
    $(MCUBOOT_CY_PATH)/cy_flash_pal/include\
    $(MCUBOOT_CY_PATH)/cy_flash_pal/flash_qspi\
    $(MCUBOOT_CY_PATH)/cy_flash_pal/include/flash_map_backend\
    $(MCUBOOT_CY_PATH)/platforms/retarget_io_pdl\
    $(MCUBOOTAPP_PATH)\
    $(MCUBOOTAPP_PATH)/sysflash\
    $(MCUBOOTAPP_PATH)/os\
    $(MCUBOOTAPP_PATH)/config
