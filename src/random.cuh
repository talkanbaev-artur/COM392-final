#ifndef RANDOM_UTILS_H
#define RANDOM_UTILS_H

#include "gpuCode.h"

//This struct hold the mean and standard deviation values for the normal distribution calculation
//Its main application is to hold value, used to calculate random values.
struct nd_value
{
	double mean, s_deviance;
};

//This struct is used to hold values for a truncated normal distribution value generation
struct tnd_value
{
	double mean, s_deviance, a, b;
};

//normal function runs the normal distribution selection on gpu using the nd_value struct. Shorthand utility
__device__ double normal(curandState_t *state, nd_value inps);

//tnormal function is used to generate the integer values in bounded regions using truncated normal distribution
//note: the tnd is here is not rescaled or normalised - pdf is less than 1, as values are simply clamped
__device__ int tnormal(curandState_t *state, tnd_value inps);

#endif