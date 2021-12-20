#ifndef SIMULATION_PARAMS
#define SIMULATION_PARAMS

#include "cuda_runtime.h"
#include "cuda.h"

class Params
{
public:
	int height, width;
	long populationSize;

	double virusEnvSupport;
	double virusNtr;
	__host__ __device__ ~Params() {}
	Params(int height, int width) : height(height), width(width),
									populationSize(height * width){};
	int getWidth() { return width; }
	int getHeight() { return height; }
	long getPopSize() { return populationSize; }
};

#endif