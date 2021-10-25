/******************************************************************************
* File Name:   main.c
*
* Description: This is the source code for the CE230650 - PSoC 6 MCU: MCUboot-
*              Based Basic Bootloader code example for ModusToolbox.
*
* Related Document: See README.md
*
*******************************************************************************
* Copyright 2020-2021, Cypress Semiconductor Corporation (an Infineon company) or
* an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
*
* This software, including source code, documentation and related
* materials ("Software") is owned by Cypress Semiconductor Corporation
* or one of its affiliates ("Cypress") and is protected by and subject to
* worldwide patent protection (United States and foreign),
* United States copyright laws and international treaty provisions.
* Therefore, you may use this Software only as provided in the license
* agreement accompanying the software package from which you
* obtained this Software ("EULA").
* If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
* non-transferable license to copy, modify, and compile the Software
* source code solely for use in connection with Cypress's
* integrated circuit products.  Any reproduction, modification, translation,
* compilation, or representation of this Software except as specified
* above is prohibited without the express written permission of Cypress.
*
* Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
* reserves the right to make changes to the Software without notice. Cypress
* does not assume any liability arising out of the application or use of the
* Software or any product or circuit described in the Software. Cypress does
* not authorize its products for use in any products where a malfunction or
* failure of the Cypress product may reasonably be expected to result in
* significant property damage, injury or death ("High Risk Product"). By
* including Cypress's product in a High Risk Product, the manufacturer
* of such system or application assumes all risk of such use and in doing
* so agrees to indemnify Cypress against all liability.
*******************************************************************************/

#include "cybsp.h"
#include "cyhal.h"
#include "cy_retarget_io.h"

/* MCUboot header file */
#include "bootutil/bootutil.h"

/* Watchdog header file */
#include "watchdog.h"

/*******************************************************************************
* Macros
********************************************************************************/
/* LED turn off and on interval based on BOOT or UPGRADE image*/
#ifdef BOOT_IMG
    #define LED_TOGGLE_INTERVAL_MS         (1000u)
    #define IMG_TYPE                       "BOOT"
#elif defined(UPGRADE_IMG)
    #define LED_TOGGLE_INTERVAL_MS         (250u)
    #define IMG_TYPE                       "UPGRADE"
#else
    #error "[BlinkyApp] Please define the image type: BOOT_IMG or UPGRADE_IMG\n"
#endif

#ifndef USER_APP_START
#define USER_APP_START 0x10018000UL
#endif

#ifndef USER_APP_SIZE
#define USER_APP_SIZE  0x10000UL
#endif

/* Img_ok offset in the slot trailer */
#define USER_SWAP_IMAGE_OK_OFFS                 (24UL)
#define USER_SWAP_IMAGE_OK                      (1UL)

/* User input to mark the upgrade image in primary slot permanent */
#define UPGRADE_IMG_PERMANENT_CAPITAL           ('Y')
#define UPGRADE_IMG_PERMANENT_SMALL             ('y')

/* UART function parameter value to wait forever */
#define UART_WAIT_FOR_EVER                      (0)

/*******************************************************************************
* Function Prototypes
********************************************************************************/
#if (SWAP_ENABLED == 1) && defined(UPGRADE_IMG)
static cy_en_flashdrv_status_t flash_write_byte(uint32_t address, uint8_t data);
#endif

/******************************************************************************
 * Function Name: main
 ******************************************************************************
 * Summary:
 *  System entrance point. This function initializes system resources & 
 *  peripherals, initializes retarget IO, and toggles the user LED at a
 *  configured interval. 
 *
 * Parameters:
 *  void
 *
 * Return:
 *  int
 *
 ******************************************************************************/
int main(void)
{
    cy_rslt_t result;

    /* Initialize the device and board peripherals */
    result = cybsp_init();
    CY_ASSERT(result == CY_RSLT_SUCCESS);

    /* Enable global interrupts */
    __enable_irq();
    
    /* Initialize retarget-io to use the debug UART port */
    result = cy_retarget_io_init(CYBSP_DEBUG_UART_TX, CYBSP_DEBUG_UART_RX, CY_RETARGET_IO_BAUDRATE);
    CY_ASSERT(result == CY_RSLT_SUCCESS);

    /* Initialize the User LED */
    result = cyhal_gpio_init(CYBSP_USER_LED, CYHAL_GPIO_DIR_OUTPUT,
              CYHAL_GPIO_DRIVE_STRONG, CYBSP_LED_STATE_OFF);
    CY_ASSERT(result == CY_RSLT_SUCCESS);
    
    (void) result; /* To avoid compiler warning in release build */

    printf("\n=========================================================\n");
    printf("[BlinkyApp] Image Type: %s, Version: %d.%d.%d, CPU: CM4\n", 
           IMG_TYPE, APP_VERSION_MAJOR, APP_VERSION_MINOR, APP_VERSION_BUILD);
    printf("\n=========================================================\n");

    /* Update watchdog timer to mark successful start up of application */
    cy_wdg_kick();
    cy_wdg_free();
    printf("[BlinkyApp] Watchdog timer started by the bootloader is now turned off to mark the successful start of Blinky app.\r\n");

#if (SWAP_ENABLED == 1) && defined(UPGRADE_IMG)

    uint32_t img_ok_addr;
    char response;

    printf("[BlinkyApp] Do you want to mark the upgrade image in primary slot permanent (Y/N) ?\r\n");
    cyhal_uart_getc(&cy_retarget_io_uart_obj, &response, UART_WAIT_FOR_EVER);
    printf("[BlinkyApp] Received response: %c\r\n", response);

    if((UPGRADE_IMG_PERMANENT_CAPITAL == response) || (UPGRADE_IMG_PERMANENT_SMALL == response))
    {
        /* Write Image OK flag to the slot trailer, so MCUBoot-loader
         * will not revert the new image.
         */
        img_ok_addr = USER_APP_START + USER_APP_SIZE - USER_SWAP_IMAGE_OK_OFFS;

        if (*((uint8_t *)img_ok_addr) != USER_SWAP_IMAGE_OK)
        {
            result = flash_write_byte(img_ok_addr, USER_SWAP_IMAGE_OK);
            if (CY_FLASH_DRV_SUCCESS == result)
            {
                printf("[BlinkyApp] SWAP Status : Image OK was set.\r\n");
            }
            else
            {
                printf("[BlinkyApp] SWAP Status : Failed to set Image OK.\r\n");
            }
        }
        else
        {
            printf("[BlinkyApp] Image OK is already set in trailer\r\n");
        }
    }
    else
    {
        printf("[BlinkyApp] The upgrade image was not marked permanent. Revert swap will happen in the next boot.\r\n");
    }

#endif

    printf("[BlinkyApp] User LED toggles at %d msec interval\r\n\n", LED_TOGGLE_INTERVAL_MS);

    for (;;)
    {
        /* Toggle the user LED periodically */
        cyhal_system_delay_ms(LED_TOGGLE_INTERVAL_MS);
        cyhal_gpio_toggle(CYBSP_USER_LED);
    }

    return 0;
}

#if (SWAP_ENABLED == 1) && defined(UPGRADE_IMG)
/******************************************************************************
 * Function Name: flash_write_byte
 ******************************************************************************
 * Summary:
 *  Writes 1 byte `data` into flash memory at `address`
 *  It does a sequence of RD/Modify/WR of data in a Flash Row.
 *
 * Parameters:
 *  uint32_t address : Address in the flash memory where the data is written.
 *  uint8_t data : The value that has to be written in flash.
 *
 * Return:
 *  cy_en_flashdrv_status_t
 *
 ******************************************************************************/
static cy_en_flashdrv_status_t flash_write_byte(uint32_t address, uint8_t data)
{
    cy_en_flashdrv_status_t result = CY_FLASH_DRV_ERR_UNC;
    uint32_t row_addr = 0;
    uint8_t row_buff[CY_FLASH_SIZEOF_ROW];

    /* Calculate the starting address of the flash row. */
    row_addr = (address / CY_FLASH_SIZEOF_ROW) * CY_FLASH_SIZEOF_ROW;

    /* preserving Row */
    memcpy(row_buff, (void *)row_addr, sizeof(row_buff));

    /* Modifying the target byte */
    row_buff[address % CY_FLASH_SIZEOF_ROW] = data;

    /* Programming updated row back */
    result = Cy_Flash_WriteRow(row_addr, (const uint32_t *)row_buff);

    return result;
}
#endif  /* (SWAP_ENABLED == 1) && defined(UPGRADE_IMG) */


/* [] END OF FILE */

