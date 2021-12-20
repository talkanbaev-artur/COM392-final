#include "simulationData.h"
#include <stdio.h>
DailyRuntimeData::DailyRuntimeData(/* args */)
{
	s = i = r = 0;
	gV = 0;
}

DailyRuntimeData::~DailyRuntimeData()
{
}

SimulationData::SimulationData(Params p)
{
	printf("Starting simulation data intialisation process...\n");
	this->populationSize = p.getPopSize();

	//we use the default 32x32 thread block size which gives max 1024 tpb.
	//it would be usefull to use 30x32 to fit this pattern into full hd samples
	this->threads.x = 32;
	this->threads.y = 32;
	//round up the number of blocks to fit all data
	this->blocks.x = (p.getWidth() + 31) / 32;
	this->blocks.y = (p.getHeight() + 31) / 32;

	long commMemSize = this->blocks.x * this->blocks.y * sizeof(Community);

	cudaError err;

	err = cudaMalloc((void **)&(this->rand), this->populationSize * sizeof(curandState));
	if (err != cudaSuccess)
	{
		printf("cuda error allocating random = %s\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	err = cudaMalloc((void **)&(this->communities), commMemSize);
	if (err != cudaSuccess)
	{
		printf("cuda error allocating communities memory = %s\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	err = cudaMalloc((void **)&(this->virus), sizeof(Virus));
	if (err != cudaSuccess)
	{
		printf("cuda error allocating virus memory = %s\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	err = cudaMalloc((void **)&(this->population), this->populationSize * sizeof(Individual));
	if (err != cudaSuccess)
	{
		printf("cuda error allocating population memory = %s\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}
	err = cudaMalloc((void **)&(this->rgb), this->populationSize * sizeof(float3));
	if (err != cudaSuccess)
	{
		printf("cuda error allocating texture rgb map = %s\n", cudaGetErrorString(err));
		exit(EXIT_FAILURE);
	}

	int *res, res2;
	cudaMalloc((void **)&res, sizeof(int));

	initialiseCuRand<<<blocks, threads>>>(this->populationSize, this->rand);
	initialisePopulation<<<blocks, threads>>>(populationSize, p, population, rand);
	initVirus<<<1, 1>>>(p, virus);
	initCommunities<<<blocks, 1>>>(blocks.x * blocks.y, communities);

	cudaMemcpy(&res2, res, sizeof(int), cD2H);
	printf("Simulation data successfully initialised\n");
}

__global__ void initialiseCuRand(int population, curandState *curand)
{
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	if (tid < population)
	{
		curand_init(1, tid, 0, &curand[tid]);
	}
}

__global__ void initialisePopulation(int population, Params p, Individual *people, curandState *c)
{
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	if (tid < population)
	{
		Individual i(p, &c[tid]);
		people[tid] = i;
	}
}

__global__ void initVirus(Params p, Virus *v)
{
	Virus vl(p);
	*v = vl;
}
__global__ void initCommunities(int comNum, Community *c)
{
	int bid = blockIdx.y * blockDim.y + blockIdx.x;
	if (bid < comNum)
	{
		Community c_l;
		c[bid] = c_l;
	}
}

SimulationData::~SimulationData()
{
	cudaFree(this->rgb);
	cudaFree(this->rand);
	cudaFree(this->population);
	cudaFree(this->communities);
	cudaFree(this->virus);
	printf("Successfully finished simulation data lifecycle\n");
}