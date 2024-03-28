################################################################################
# \file common_libs.mk
# \version 1.0
#
# \brief
# Configuration file for adding/removing source files. Modify this file
# to suit the application needs.
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

MCUBOOT_PATH=$(SEARCH_mcuboot)
MCUBOOT_CY_PATH=$(MCUBOOT_PATH)/boot/cypress
MCUBOOTAPP_PATH=$(MCUBOOT_CY_PATH)/MCUBootApp

################################################################################
# MCUboot Files
################################################################################

SOURCES+=\
    $(wildcard $(MCUBOOT_CY_PATH)/libs/retarget-io/*.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/platforms/security_counter/*.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/platforms/security_counter/$(FAMILY)/*.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/platforms/memory/*.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/platforms/memory/$(FAMILY)/*.c)\
    $(MCUBOOT_CY_PATH)/platforms/utils/$(FAMILY)/cyw_platform_utils.c

# External flash includes and sources files
ifeq ($(USE_EXTERNAL_FLASH), 1)
SOURCES+=\
    $(wildcard $(MCUBOOT_CY_PATH)/platforms/memory/external_memory/*.c)\
    $(wildcard $(MCUBOOT_CY_PATH)/platforms/memory/$(FAMILY)/flash_qspi/*.c)

INCLUDES+=\
    $(MCUBOOT_CY_PATH)/platforms/memory/external_memory\
    $(MCUBOOT_CY_PATH)/platforms/memory/$(FAMILY)/flash_qspi
endif
    
INCLUDES+=\
    ../keys\
    $(MCUBOOT_PATH)/boot/bootutil/include\
    $(MCUBOOT_PATH)/boot/bootutil/include/bootutil\
    $(MCUBOOT_PATH)/boot/bootutil/src\
    $(MCUBOOT_CY_PATH)/libs/retarget-io\
    $(MCUBOOT_CY_PATH)/platforms/security_counter/$(FAMILY)\
    $(MCUBOOT_CY_PATH)/platforms/security_counter\
    $(MCUBOOT_CY_PATH)/platforms/memory\
    $(MCUBOOT_CY_PATH)/platforms/memory/flash_map_backend\
    $(MCUBOOT_CY_PATH)/platforms/memory/$(FAMILY)\
    $(MCUBOOT_CY_PATH)/platforms/memory/$(FAMILY)/include\
    $(MCUBOOT_CY_PATH)/platforms/utils/$(FAMILY)\
    $(MCUBOOTAPP_PATH)/config\
    $(MCUBOOTAPP_PATH)
