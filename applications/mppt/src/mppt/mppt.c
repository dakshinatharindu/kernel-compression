#include <stdio.h>
#include <math.h>
#include "mppt.h"

// Global variables
double power_prev = 0;
double voltage_prev = 0;
double voltage = 0;

// Mathematical model of the IV curve of a solar panel
void iv_curve(double *voltage, double *current)
{
    if (*voltage < 0)
    {
        *current = 8.3;
    }
    else if (*voltage > 36)
    {
        *current = 0;
    }
    else
    {
        *current = fmax(1 / (sqrt(*voltage) - 6.1181) + 8.4634, 0);
    }
}

void mppt()
{
    double power_diff, voltage_diff, current, power;

    // Sense
    iv_curve(&voltage, &current);
    power = voltage * current;

    // Calculate the power difference and voltage difference
    power_diff = power - power_prev;
    voltage_diff = voltage - voltage_prev;

    // Remember the previous values of voltage and power
    voltage_prev = voltage;
    power_prev = power;

    if (power_diff >= 0)
    {
        if (voltage_diff >= 0)
        {
            voltage += 1;
        }
        else
        {
            voltage -= 1;
        }
    }
    else
    {
        if (voltage_diff >= 0)
        {
            voltage -= 1;
        }
        else
        {
            voltage += 1;
        }
    }
}