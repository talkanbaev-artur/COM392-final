#include "random.cuh"
__device__ int tnormal(curandState_t *state, tnd_value inps)
{
	double result = static_cast<int>(curand_normal_double(state) * inps.s_deviance + inps.mean + 0.49);
	return max(inps.a, min(result, inps.b));
}

__device__ double normal(curandState_t *state, nd_value inps)
{
	return curand_normal_double(state) * inps.s_deviance + inps.mean;
}