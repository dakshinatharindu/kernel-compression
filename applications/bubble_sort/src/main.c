#include <stdio.h>
#include <zephyr/kernel.h>
#include <string.h>
#include <fcntl.h>
#include "libmin.h"

#define STACKSIZE 1024
#define PRIORITY 7

// supported sizes: 256 (default), 512, 1024, 2048
#define DATASET_SIZE 256
int data[DATASET_SIZE];

// total swaps executed so far
unsigned long swaps = 0;

void print_data(int *data, unsigned size)
{
    libmin_printf("DATA DUMP:\n");
    for (unsigned i = 0; i < size; i++)
        libmin_printf("  data[%u] = %d\n", i, data[i]);
}

void bubblesort(int *data, unsigned size)
{
    for (unsigned i = 0; i < size - 1; i++)
    {
        int swapped = FALSE;
        for (unsigned j = 0; j < size - 1; j++)
        {
            if (data[j] > data[j + 1])
            {
                int tmp = data[j];
                data[j] = data[j + 1];
                data[j + 1] = tmp;
                swapped = TRUE;
                swaps++;
            }
        }
        // done?
        if (!swapped)
            break;
    }
}

void thread1(void)
{
    libmin_srand(42);
    // mysrand(time(NULL));

    // initialize the array to sort
    for (unsigned i = 0; i < DATASET_SIZE; i++)
        data[i] = libmin_rand();
    print_data(data, DATASET_SIZE);

    bubblesort(data, DATASET_SIZE);
    print_data(data, DATASET_SIZE);

    // check the array
    for (unsigned i = 0; i < DATASET_SIZE - 1; i++)
    {
        if (data[i] > data[i + 1])
        {
            libmin_printf("ERROR: data is not properly sorted.\n");
            return -1;
        }
    }
    libmin_printf("INFO: %lu swaps executed.\n", swaps);
    libmin_printf("INFO: data is properly sorted.\n");

    // libmin_success();
}

void thread2(void)
{
    while (1)
    {
        k_msleep(1000);
    }
}

K_THREAD_DEFINE(thread1_id, STACKSIZE, thread1, NULL, NULL, NULL,
                PRIORITY, 0, 0);
K_THREAD_DEFINE(thread2_id, STACKSIZE, thread2, NULL, NULL, NULL,
                PRIORITY, 0, 0);
