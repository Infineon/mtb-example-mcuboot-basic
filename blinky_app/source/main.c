/******************************************************************************
* File Name:   main.c
*
* Description: This is the source code for the CE230650 - PSoC 6 MCU: MCUboot-
*              Based Basic Bootloader code example for ModusToolbox.
*
* Related Document: See README.md
*
*******************************************************************************
* Copyright 2020-2024, Cypress Semiconductor Corporation (an Infineon company) or
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

#include "cy_pdl.h"
#include "cyhal.h"
#include "cybsp.h"
#include "cy_retarget_io.h"
#if !(SWAP_DISABLED) && defined(UPGRADE_IMAGE)
/* Header file which contains the function to Write Image OK flag to the slot trailer */
#include "set_img_ok.h"
#endif

/*******************************************************************************
* Macros
********************************************************************************/
/* LED turn off and on interval based on BOOT or UPGRADE image*/
#ifdef BOOT_IMAGE
    #define LED_TOGGLE_INTERVAL_MS         (1000u)
#elif defined(UPGRADE_IMAGE)
    #define LED_TOGGLE_INTERVAL_MS         (250u)
#endif

#define VERSION_MESSAGE_VER         "[Blinky App] Version:"

#define IMAGE_TYPE_MESSAGE_VER      "IMAGE_TYPE:"

#define CORE_NAME_MESSAGE_VER       "CPU:"

/* User input to mark the upgrade image in primary slot permanent */
#define UPGRADE_IMG_PERMANENT_CAPITAL           ('Y')
#define UPGRADE_IMG_PERMANENT_SMALL             ('y')

/* UART function parameter value to wait forever */
#define UART_WAIT_FOR_EVER                      (0)

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
    cy_rslt_t result = CY_RSLT_TYPE_ERROR;

    /* Update watchdog timer to mark successful start up of application */
    /* Disabling the Watchdog timer started by the bootloader */
    cyhal_wdt_free(NULL);

    /* Initialize the device and board peripherals */
    result = cybsp_init();

    /* Board init failed. Stop program execution */
    if (CY_RSLT_SUCCESS != result)
    {
        CY_ASSERT(0);
    }

    /* Enable global interrupts */
    __enable_irq();
    
    /* Initialize retarget-io to use the debug UART port */
    result = cy_retarget_io_init(CYBSP_DEBUG_UART_TX, CYBSP_DEBUG_UART_RX, CY_RETARGET_IO_BAUDRATE);

    /* Retarget-io init failed. Stop program execution */
    if (CY_RSLT_SUCCESS != result)
    {
        CY_ASSERT(0);
    }

    /* Initialize the User LED */
    result = cyhal_gpio_init(CYBSP_USER_LED, CYHAL_GPIO_DIR_OUTPUT,
              CYHAL_GPIO_DRIVE_STRONG, CYBSP_LED_STATE_OFF);

    /* GPIO init failed. Stop program execution */
    if (CY_RSLT_SUCCESS != result)
    {
        CY_ASSERT(0);
    }
    
    (void) result; /* To avoid compiler warning in release build */

    printf("\n=========================================================\n");
    printf("%s%s %s%s %s%s\r", VERSION_MESSAGE_VER, IMG_VER_MSG,
    IMAGE_TYPE_MESSAGE_VER, IMG_TYPE_MSG, CORE_NAME_MESSAGE_VER,
    CORE_NAME_MSG);
    printf("\n=========================================================\n");

    printf("[Blinky App] Watchdog timer started by the bootloader is now turned off to mark the successful start of Blinky app.\r\n");

/* After a successful swap-based upgrade*/
#if !(SWAP_DISABLED) && defined(UPGRADE_IMAGE)
    int img_ok_status = IMG_OK_SET_FAILED;
    uint8_t response;

    if (*((uint8_t*) IMG_OK_ADDR) != USER_SWAP_IMAGE_OK)
    {
        printf("[Blinky App] Do you want to mark the upgrade image in primary slot permanent (Y/N) ?\r\n");
        cyhal_uart_getc(&cy_retarget_io_uart_obj, &response, UART_WAIT_FOR_EVER);
        printf("[Blinky App] Received response: %c\r\n", response);

        if ((UPGRADE_IMG_PERMANENT_CAPITAL == response) || (UPGRADE_IMG_PERMANENT_SMALL == response))
        {
            /* Write Image OK flag to the slot trailer, so MCUBoot-loader
             * will not revert new image
             */
            img_ok_status = set_img_ok(IMG_OK_ADDR, USER_SWAP_IMAGE_OK);

            if (IMG_OK_SET_SUCCESS == img_ok_status)
            {
                printf("[Blinky App] SWAP Status : Image OK was set at 0x%08x.\r\n", IMG_OK_ADDR);
            }
            else
            {
                printf("[Blinky App] SWAP Status : Failed to set Image OK.\r\n");
            }
        }
        else
        {
            printf("[Blinky App] The upgrade image was not marked permanent. Revert swap will happen in the next boot.\r\n");
        }
    } 
    else
    {
        printf("[Blinky App] Image OK is already set in trailer\r\n");
    }
#endif /* !(SWAP_DISABLED) && defined(UPGRADE_IMAGE) */

    printf("[Blinky App] User LED toggles at %d msec interval\r\n\n", LED_TOGGLE_INTERVAL_MS);

    for (;;)
    {
        /* Toggle the user LED periodically */
        cyhal_system_delay_ms(LED_TOGGLE_INTERVAL_MS);
        /* Invert the user LED state */
        cyhal_gpio_toggle(CYBSP_USER_LED);
    }

    return 0;
}

/* [] END OF FILE */
