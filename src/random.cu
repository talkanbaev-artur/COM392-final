#include "random.cuh"
__device__ int tnormal(curandState_t *state, tnd_value inps)
{
	int result = static_cast<int>(curand_log_normal_double(state, inps.mean, inps.s_deviance) + 0.5);
	return max((int)inps.a, min(result, (int)inps.b));
}

__device__ double normal(curandState_t *state, nd_value inps)
{
	return curand_log_normal_double(state, inps.mean, inps.s_deviance);
}