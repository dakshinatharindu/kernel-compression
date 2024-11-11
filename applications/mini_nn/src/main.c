#include <stdio.h>
#include <zephyr/kernel.h>
#include <string.h>
#include <fcntl.h>

#define STACKSIZE 1024
#define PRIORITY 7

void nn();

void thread1(void)
{
	nn();
}

void thread2(void)
{
	while (1)
	{
		// printf("Hello from thread2\n");
		k_msleep(1000);
	}
}

K_THREAD_DEFINE(thread1_id, STACKSIZE, thread1, NULL, NULL, NULL,
				PRIORITY, 0, 0);
K_THREAD_DEFINE(thread2_id, STACKSIZE, thread2, NULL, NULL, NULL,
				PRIORITY, 0, 0);
