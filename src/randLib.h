/**************************************************************************
*
*   A helper library for Assignment 1 by Michael Brady
*
**************************************************************************/

#ifndef __RANDLIB_H__
#define __RANDLIB_H__

#include <stdlib.h> // needed for srand()
#include <time.h> // needed for seed_randoms()

/*************************************************************************/
// SEED THE RANDOM NUMBER GENERATOR WITH THE TIME ON THE SYSTEM CLOCK
void seed_randoms(void)
{
    time_t x;
    time(&x);
    srand(x);
}

/*************************************************************************/
// GENERATE A RANDOM VALUE BETWEEN -1.0 AND 1.0
float rand_weight(void)
{
    return((float) (((rand()*2.0)/RAND_MAX) - 1.0));
}

/*************************************************************************/
// GENERATE A RANDOM VALUE BETWEEN 0.0 and 1.0
float rand_frac(void)
{
    return((float) ((rand()*1.0)/RAND_MAX));
}

/*************************************************************************/
#endif /*__RANDLIB_H__*/
