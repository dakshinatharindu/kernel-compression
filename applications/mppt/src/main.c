/*
 * Copyright (c) 2012-2014 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdio.h>
#include <zephyr/kernel.h>
#include "mppt/mppt.h"

#define STACKSIZE 1024
#define PRIORITY 7

void thread1(void)
{
	while (1) {
		// printf("Hello from thread1\n");
		mppt();
		k_msleep(2000);
	}
}

void thread2(void)
{
	while (1) {
		// printf("Hello from thread2\n");
		k_msleep(1000);
	}
}

K_THREAD_DEFINE(thread1_id, STACKSIZE, thread1, NULL, NULL, NULL,
		PRIORITY, 0, 0);
K_THREAD_DEFINE(thread2_id, STACKSIZE, thread2, NULL, NULL, NULL,
		PRIORITY, 0, 0);
