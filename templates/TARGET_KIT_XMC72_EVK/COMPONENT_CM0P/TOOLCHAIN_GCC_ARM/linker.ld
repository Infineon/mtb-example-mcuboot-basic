/***************************************************************************//**
* \file xmc7200_x8384_cm0plus.ld
* \version 1.0.0
*
* Linker file for the GNU C compiler.
*
* The main purpose of the linker script is to describe how the sections in the
* input files should be mapped into the output file, and to control the memory
* layout of the output file.
*
* \note The entry point location is fixed and starts at 0x10000000. The valid
* application image should be placed there.
*
* \note The linker files included with the PDL template projects must be generic
* and handle all common use cases. Your project may not use every section
* defined in the linker files. In that case you may see warnings during the
* build process. In your project, you can simply comment out or remove the
* relevant code in the linker file.
*
********************************************************************************
* \copyright
* Copyright 2021 Cypress Semiconductor Corporation
* SPDX-License-Identifier: Apache-2.0
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*******************************************************************************/

OUTPUT_FORMAT ("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
GROUP(-lgcc -lc -lnosys )
SEARCH_DIR(.)
GROUP(libgcc.a libc.a libm.a libnosys.a)
ENTRY(Reset_Handler)

/* The size of the stack section at the end of CM7_x SRAM */
STACK_SIZE = 0x1000;
RAMVECTORS_ALIGNMENT                = 128;

sram_start_reserve                  = 0;
sram_private_for_srom               = 0x00000800; /* Private SRAM for SROM (e.g. API processing). Reserved at the beginning */

cm0plus_sram_reserve                = CM0P_RAM_SIZE;   /* cm0 sram size */
cm0plus_code_flash_reserve          = CM0P_FLASH_SIZE; /* cm0 flash size */
cm7_code_flash_reserve              = USER_APP_FLASH_SIZE;

sram_base_address                   = 0x28000000;
code_flash_base_address             = 0x10000000;
code_flash_total_size               = CM0P_FLASH_SIZE;

_base_SRAM_CM0P                     = sram_base_address + sram_start_reserve + sram_private_for_srom;
_size_SRAM_CM0P                     = cm0plus_sram_reserve - sram_start_reserve - sram_private_for_srom;
_base_CODE_FLASH_CM0P               = code_flash_base_address;
_size_CODE_FLASH_CM0P               = cm0plus_code_flash_reserve;

/* Fixed Addesses */
_base_WORK_FLASH                    = 0x14000000;
_size_WORK_FLASH                    = 0x00040000;   /* 256K Work flash */
_base_SFLASH_USER_DATA              = 0x17000800;
_size_SFLASH_USER_DATA              = 0x00000800;
_base_SFLASH_NAR                    = 0x17001A00;
_size_SFLASH_NAR                    = 0x00000200;
_base_SFLASH_PUB_KEY                = 0x17006400;
_size_SFLASH_PUB_KEY                = 0x00000C00;
_base_SFLASH_APP_PROT               = 0x17007600;
_size_SFLASH_APP_PROT               = 0x00000200;
_base_SFLASH_TOC2                   = 0x17007C00;
_size_SFLASH_TOC2                   = 0x00000200;
_base_XIP                           = 0x60000000;
_size_XIP                           = 0x08000000;
_base_EFUSE                         = 0x90700000;
_size_EFUSE                         = 0x00100000;
_base_CODE_FLASH_CM7_0              = code_flash_base_address + cm0plus_code_flash_reserve;
_size_CODE_FLASH_CM7_0              = cm7_code_flash_reserve;
/* In case of single CM7 device, CM7_1 values should not be used */
_base_CODE_FLASH_CM7_1              = code_flash_base_address + cm0plus_code_flash_reserve;
_size_CODE_FLASH_CM7_1              = cm7_code_flash_reserve;


/* Force symbol to be entered in the output file as an undefined symbol. Doing
* this may, for example, trigger linking of additional modules from standard
* libraries. You may list several symbols for each EXTERN, and you may use
* EXTERN multiple times. This command has the same effect as the -u command-line
* option.
*/
EXTERN(Reset_Handler)

/* The MEMORY section below describes the location and size of blocks of memory in the target.
* Use this section to specify the memory regions available for allocation.
*/
MEMORY
{
    /* The ram and flash regions control RAM and flash memory allocation for the CM33 core.
     */
    cm0_ram         (rxw)       : ORIGIN = _base_SRAM_CM0P,             LENGTH = _size_SRAM_CM0P
    cm0_flash       (rx)        : ORIGIN = _base_CODE_FLASH_CM0P,       LENGTH = _size_CODE_FLASH_CM0P

    /* This is a 256K flash region used for EEPROM emulation. This region can also be used as the general purpose flash.
     * You can assign sections to this memory region for only one of the cores.
     */
    em_eeprom           (rw)        : ORIGIN = _base_WORK_FLASH,            LENGTH = _size_WORK_FLASH           /* WORK flash */

    /* The following regions define device specific memory regions and must not be changed. */
    sflash_user_data    (rx)        : ORIGIN = _base_SFLASH_USER_DATA,      LENGTH = _size_SFLASH_USER_DATA     /* Supervisory flash: User data */
    sflash_nar          (rx)        : ORIGIN = _base_SFLASH_NAR,            LENGTH = _size_SFLASH_NAR            /* Supervisory flash: Normal Access Restrictions (NAR) */
    sflash_public_key   (rx)        : ORIGIN = _base_SFLASH_PUB_KEY,        LENGTH = _size_SFLASH_PUB_KEY       /* Supervisory flash: Public Key */
    sflash_app_prot     (rx)        : ORIGIN = _base_SFLASH_APP_PROT,       LENGTH = _size_SFLASH_APP_PROT
    sflash_toc_2        (rx)        : ORIGIN = _base_SFLASH_TOC2,           LENGTH = _size_SFLASH_TOC2          /* Supervisory flash: Table of Content # 2 */
    xip                 (rx)        : ORIGIN = _base_XIP,                   LENGTH = _size_XIP                  /* XIP: 128 MB */
    efuse               (rx)        : ORIGIN = _base_EFUSE,                 LENGTH = _size_EFUSE                /* 1MB */
    cm7_0_flash         (rx)        : ORIGIN = _base_CODE_FLASH_CM7_0,      LENGTH = _size_CODE_FLASH_CM7_0
    cm7_1_flash         (rx)        : ORIGIN = _base_CODE_FLASH_CM7_1,      LENGTH = _size_CODE_FLASH_CM7_1
}

/* Library configurations */
GROUP(libgcc.a libc.a libm.a libnosys.a)

SECTIONS
{
    .cy_app_header :
    {
        __app_header_start = .;
        KEEP(*(.cy_app_header))
    } > cm0_flash

    /* Cortex-M0+ application flash area */
    .text :
    {
        /* Cortex-M0+ flash vector table must be aligned to 1024 bytes */
        . = ALIGN(1024);
        __Vectors = . ;
        KEEP(*(.vectors))
        . = ALIGN(4);
        __Vectors_End = .;
        __Vectors_Size = __Vectors_End - __Vectors;
        __end__ = .;

        . = ALIGN(4);
        *(.text*)

        KEEP(*(.init))
        KEEP(*(.fini))

        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)

        /* Read-only code (constants). */
        *(.rodata .rodata.* .constdata .constdata.* .conststring .conststring.*)

        KEEP(*(.eh_frame*))
    } > cm0_flash


    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > cm0_flash

    __exidx_start = .;

    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > cm0_flash
    __exidx_end = .;


    /* To copy multiple ROM to RAM sections,
     * uncomment .copy.table section and,
     * define __STARTUP_COPY_MULTIPLE in startup_psoc6_02_cm4.S */
    .copy.table :
    {
        . = ALIGN(4);
        __copy_table_start__ = .;

        /* Copy data section to RAM */
        LONG (__etext)                                      /* From */
        LONG (__data_start__)                               /* To   */
        LONG ((__data_end__ - __data_start__)/4)            /* Size */

        __copy_table_end__ = .;
    } > cm0_flash


    /* To clear multiple BSS sections,
     * uncomment .zero.table section and,
     * define __STARTUP_CLEAR_BSS_MULTIPLE in startup_psoc6_02_cm4.S */
    .zero.table :
    {
        . = ALIGN(4);
        __zero_table_start__ = .;
        LONG (__bss_start__)
        LONG ((__bss_end__ - __bss_start__)/4)
        __zero_table_end__ = .;
    } > cm0_flash

    __etext =  . ;


    .ramVectors (NOLOAD) :
    {
        . = ALIGN(RAMVECTORS_ALIGNMENT);
        __ram_vectors_start__ = .;
        KEEP(*(.ram_vectors))
        __ram_vectors_end__   = .;
    } > cm0_ram


    .data __ram_vectors_end__ :
    {
        . = ALIGN(4);
        __data_start__ = .;

        *(vtable)
        *(.data*)

        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        KEEP(*(.jcr*))
        . = ALIGN(4);

        KEEP(*(.cy_ramfunc*))
        . = ALIGN(4);

        __data_end__ = .;

    } > cm0_ram AT>cm0_flash


    /* Place variables in the section that should not be initialized during the
    *  device startup.
    */
    .noinit (NOLOAD) : ALIGN(8)
    {
      KEEP(*(.noinit))
    } > cm0_ram


    /* The uninitialized global or static variables are placed in this section.
    *
    * The NOLOAD attribute tells linker that .bss section does not consume
    * any space in the image. The NOLOAD attribute changes the .bss type to
    * NOBITS, and that  makes linker to A) not allocate section in memory, and
    * A) put information to clear the section with all zeros during application
    * loading.
    *
    * Without the NOLOAD attribute, the .bss section might get PROGBITS type.
    * This  makes linker to A) allocate zeroed section in memory, and B) copy
    * this section to RAM during application loading.
    */
    .bss (NOLOAD):
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > cm0_ram


    .heap (NOLOAD):
    {
        __HeapBase = .;
        __end__ = .;
        end = __end__;
        KEEP(*(.heap*))
        . = ORIGIN(cm0_ram) + LENGTH(cm0_ram) - STACK_SIZE;
        __HeapLimit = .;
    } > cm0_ram


    /* .stack_dummy section doesn't contains any symbols. It is only
     * used for linker to calculate size of stack sections, and assign
     * values to stack symbols later */
    .stack_dummy (NOLOAD):
    {
        KEEP(*(.stack*))
    } > cm0_ram


    /* Set stack top to end of RAM, and stack limit move down by
     * size of stack_dummy section */
    __StackTop = ORIGIN(cm0_ram) + LENGTH(cm0_ram);
    __StackLimit = __StackTop - STACK_SIZE;
    PROVIDE(__stack = __StackTop);

    /* Check if data + heap + stack exceeds RAM limit */
    ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack")

    /* Used for the digital signature of the secure application.
    * The size of the section depends on the required data size. */
    .cy_app_signature :
    {
        . = ALIGN(4);
        __app_image_end = .;
        KEEP(*(.cy_app_signature))
    } > cm0_flash

    /* Emulated EEPROM Flash area */
    .cy_em_eeprom :
    {
        KEEP(*(.cy_em_eeprom))
    } > em_eeprom


    /* Supervisory Flash: User data */
    .cy_sflash_user_data :
    {
        KEEP(*(.cy_sflash_user_data))
    } > sflash_user_data


    /* Supervisory Flash: Normal Access Restrictions (NAR) */
    .cy_sflash_nar :
    {
        KEEP(*(.cy_sflash_nar))
    } > sflash_nar


    /* Supervisory Flash: Public Key */
    .cy_sflash_public_key :
    {
        KEEP(*(.cy_sflash_public_key))
    } > sflash_public_key


    /* Supervisory Flash: Table of Content # 2 */
    .cy_toc_part2 :
    {
        KEEP(*(.cy_toc_part2))
    } > sflash_toc_2

    /* Places the code in the Execute in Place (XIP) section. See the smif driver
    *  documentation for details.
    */
    cy_xip :
    {
        __cy_xip_start = .;
        KEEP(*(.cy_xip))
        __cy_xip_end = .;
    } > xip


    /* eFuse */
    .cy_efuse :
    {
        KEEP(*(.cy_efuse))
    } > efuse

    .cm7_0 ORIGIN(cm7_0_flash) :
    {
        . = ALIGN(4);
        __m7_0_code_start = . ;
        KEEP(*(.cm7_0_rom))
        __m7_0_code_end = . ;
    } > cm7_0_flash


    .cm7_1 ORIGIN(cm7_1_flash) :
    {
        . = ALIGN(4);
        __m7_1_code_start = . ;
        KEEP(*(.cm7_1_rom))
        __m7_1_code_end = . ;
    } > cm7_1_flash

}


/*============================================================
 * Symbols for use by application
 *============================================================
 */
/* The start of CM7_0/1 vector table is required by CM0+ application to correctly
 * set CPUSS->CM7_0/1_VECTOR_TABLE_BASE register before releasing CM7_0 or CM7_1 from reset
 */

__cm7_0_vector_base_linker_symbol = ORIGIN(cm7_0_flash);
__cm7_1_vector_base_linker_symbol = ORIGIN(cm7_1_flash);

__ecc_init_sram_start_address = ORIGIN(cm0_ram);
__ecc_init_sram_end_address   = ORIGIN(cm0_ram) + LENGTH(cm0_ram);

/*============================================================
 * Symbols for use by secure config
 *============================================================
 */
__secure_object_size       = __app_image_end - __app_header_start;
__app_header_vtable_offset = __Vectors - __app_header_start;

/*============================================================
 * Symbols for use by cymcuelftool
 *============================================================
 */
__cy_app_verify_start  = ORIGIN(cm0_flash);
__cy_app_verify_length = __secure_object_size;

/* Check application header placement */
ASSERT(__app_header_start == ORIGIN(cm0_flash), "Incorrect app header placement")

/* EOF */
