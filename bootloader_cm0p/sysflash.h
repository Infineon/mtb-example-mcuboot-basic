/* Manual version of auto-generated version. */

#ifndef __SYSFLASH_H__
#define __SYSFLASH_H__

#define FLASH_DEVICE_INTERNAL_FLASH        (0x7F)

#define FLASH_AREA_BOOTLOADER 0
#define FLASH_AREA_IMAGE_0 1
#define FLASH_AREA_IMAGE_1 2
#define FLASH_AREA_IMAGE_SCRATCH 3
#define FLASH_AREA_IMAGE_2 5
#define FLASH_AREA_IMAGE_3 6
#define FLASH_AREA_IMAGE_SWAP_STATUS 7

/* Uncomment if external flash is being used */
/* #define CY_BOOT_USE_EXTERNAL_FLASH */

/* use PDL-defined offset or one from SMFI config */
#if defined(TARGET_CYW9P62S1_43012_EVB_01)
    /* S25FS512S on the CYW9P62S1-43012-EVB-01 kit has the following sector
     * configuration by default: Eight 4 KB sectors, One 224 KB sector, and
     * remaining 256 KB sectors. By changing the offset, erase/write will happen
     * from the uniform sector region as MCUboot does not support working with
     * hybrid sectors.
     */
    #define CY_SMIF_BASE_MEM_OFFSET             (0x18040000)
#else
    #define CY_SMIF_BASE_MEM_OFFSET             (0x18000000)
#endif /* #if defined(TARGET_CYW9P62S1_43012_EVB_01) */

#define CY_FLASH_ALIGN                      (CY_FLASH_SIZEOF_ROW)
#define CY_FLASH_DEVICE_BASE                (CY_FLASH_BASE)

#ifndef CY_BOOT_SCRATCH_SIZE
#define CY_BOOT_SCRATCH_SIZE                (0x1000)
#endif

#ifndef CY_BOOT_SWAP_STATUS_SIZE
#define CY_BOOT_SWAP_STATUS_SIZE            BOOT_SWAP_STATUS_SIZE
#endif

#ifndef CY_BOOT_BOOTLOADER_SIZE
#define CY_BOOT_BOOTLOADER_SIZE             (0x18000)
#endif

#ifndef CY_BOOT_USE_EXTERNAL_FLASH
#define CY_BOOT_IMAGE_1_SIZE                (0x10000)
#if (MCUBOOT_IMAGE_NUMBER == 2) /* if dual-image */
#define CY_BOOT_IMAGE_2_SIZE                (0x20000)
#endif
#else
#define CY_BOOT_IMAGE_1_SIZE                (0xC0000)
#if (MCUBOOT_IMAGE_NUMBER == 2) /* if dual-image */
#define CY_BOOT_IMAGE_2_SIZE                (0xC0000)
#endif
#endif /* CY_BOOT_USE_EXTERNAL_FLASH */

#ifndef CY_BOOT_PRIMARY_1_SIZE
#define CY_BOOT_PRIMARY_1_SIZE              CY_BOOT_IMAGE_1_SIZE
#endif

#ifndef CY_BOOT_SECONDARY_1_SIZE
#define CY_BOOT_SECONDARY_1_SIZE            CY_BOOT_IMAGE_1_SIZE
#endif

#if (MCUBOOT_IMAGE_NUMBER == 2) /* if dual-image */
#ifndef CY_BOOT_PRIMARY_2_SIZE
#define CY_BOOT_PRIMARY_2_SIZE              CY_BOOT_IMAGE_2_SIZE
#endif

#ifndef CY_BOOT_SECONDARY_2_SIZE
#define CY_BOOT_SECONDARY_2_SIZE            CY_BOOT_IMAGE_2_SIZE
#endif
#endif

#if (MCUBOOT_IMAGE_NUMBER == 1)
#define FLASH_AREA_IMAGE_PRIMARY(x)    (((x) == 0) ?          \
                                         FLASH_AREA_IMAGE_0 : \
                                         FLASH_AREA_IMAGE_0)
#define FLASH_AREA_IMAGE_SECONDARY(x)  (((x) == 0) ?          \
                                         FLASH_AREA_IMAGE_1 : \
                                         FLASH_AREA_IMAGE_1)

#elif (MCUBOOT_IMAGE_NUMBER == 2)

#define FLASH_AREA_IMAGE_PRIMARY(x)    (((x) == 0) ?          \
                                         FLASH_AREA_IMAGE_0 : \
                                        ((x) == 1) ?          \
                                         FLASH_AREA_IMAGE_2 : \
                                         255)
#define FLASH_AREA_IMAGE_SECONDARY(x)  (((x) == 0) ?          \
                                         FLASH_AREA_IMAGE_1 : \
                                        ((x) == 1) ?          \
                                         FLASH_AREA_IMAGE_3 : \
                                         255)

#else
#warning "Image slot and flash area mapping is not defined"
#endif
#define CY_IMG_HDR_SIZE 0x400

#ifndef CY_FLASH_MAP_EXT_DESC
/* Uncomment in case you want to use separately defined table of flash area descriptors */
/* #define CY_FLASH_MAP_EXT_DESC */
#endif

#endif /* __SYSFLASH_H__ */
