#include "algorithm.h"
#include "individual.h"
#include "virus.h"
#include "community.h"
#include "../random.cuh"

#include <stdio.h>

__device__ void reduce(double *bl)
{
	int i = blockDim.x * blockDim.y / 2;
	while (i != 0)
	{
		int tid = threadIdx.x + threadIdx.y * blockDim.x;
		if (tid < i)
			bl[tid] += bl[tid + i];
		__syncthreads();
		i /= 2;
	}
	__syncthreads();
}

void runDay(SimulationData *sd, int day)
{
	SimulationData *gsd;
	cudaMalloc((void **)&gsd, sizeof(SimulationData));
	cudaMemcpy(gsd, sd, sizeof(SimulationData), cH2D);
	DailyRuntimeData *dd_g;
	DailyRuntimeData dd = DailyRuntimeData();

	cudaMalloc((void **)&dd_g, sizeof(DailyRuntimeData));
	cudaMemcpy(dd_g, &dd, sizeof(DailyRuntimeData), cH2D);

	runAlgorithms<<<sd->blocks, sd->threads>>>(gsd, dd_g);

	cudaMemcpy(&dd, dd_g, sizeof(DailyRuntimeData), cD2H);
	cudaMemcpy(sd, gsd, sizeof(SimulationData), cD2H);
}

__global__ void runAlgorithms(SimulationData *sd, DailyRuntimeData *drd)
{
	__shared__ double commV[1024]; // block size

	update_statuses(sd, commV);
	reduce(commV);

	infect(sd->population, sd->rand);
	drawStage(sd->population, sd->rgb, sd->populationSize);
}

__device__ void update_statuses(SimulationData *sd, double *cv)
{
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);
	int bid = blockIdx.y * blockDim.x + blockIdx.x;

	Individual individual = sd->population[tid];
	Community i_community = sd->communities[bid];
	curandState lcu = sd->rand[tid];

	Virus virus = *sd->virus;

	double individual_v = 0;

	// social activity modifier for indiv based on age
	// after 14 and till 42 this modifier > 0.9
	double daily_a = -0.0005 * pow(individual.age - 28, 2) + 1;

	switch (individual.status)
	{
	case -1: // dead
		break;
	case 0: // healthy
		break;
	case 1: // infected
		individual_v = 1 + daily_a * (i_community.sdf * tnormal(&lcu, individual.daily_contacts)) * virus.ntr;
		individual.state -= 1;
		if (individual.state >= 0)
		{
			individual.status++;
			individual.state = tnormal(&lcu, virus.illness_period);
		}
		break;
	case 2: // ill
		// x0.5 because the person is ill and expiriences symptoms reduced number of contacts
		individual_v = 0.5 * daily_a * (i_community.sdf * tnormal(&lcu, {3, 5, 0, 20})) * virus.ntr;
		individual.state -= 1;
		if (individual.state == 0)
		{
			individual.status++;
			individual.state = tnormal(&lcu, virus.recovery_period);
		}
		break;
	case 3: // recovering
		individual_v = 0.2 * daily_a * (i_community.sdf * tnormal(&lcu, {5, 5, 0, 20})) * virus.ntr;
		individual.state -= 1;
		if (individual.state == 0)
		{
			individual.status++;
			individual.state = tnormal(&lcu, {90, 10, 60, 130});
		}
		break;
	case 4: // immune
	case 5:
		individual.state -= 1;
		if (individual.state == 0)
			individual.status = 0;
		break;
	default: // super-human
		break;
	}

	cv[threadIdx.x + threadIdx.y * blockDim.x] = individual_v;
	__syncthreads();
	sd->rand[tid] = lcu;
	sd->population[tid] = individual;
	sd->communities[bid] = i_community;
}

__device__ void infect(Individual *pop, curandState *rand)
{
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	Individual in = pop[tid];
	curandState loc = rand[tid];

	// people at age of 18 are least vulnerable. and the age multiplier grows non-lineraly
	// 7.7 for 6yo, same for 30yo. At the age of 50 it is 52. 192.7 for 80yo
	double age_m = (0.05 * pow(in.age - 18, 2) + 0.5);

	double chance = curand_normal_double(&loc);
	if (chance > 0.9 && in.status != 4)
	{
		in.status = 1;
		in.state = 3;
	}
	pop[tid] = in;
	rand[tid] = loc;
}

__device__ void drawStage(Individual *population, float3 *rgb, ulong sizePopulation)
{
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	Individual individual = population[tid];
	float3 lrgb = rgb[tid];
	if (tid < sizePopulation)
	{
		if (individual.status == 0)
		{ // if not infected, draw as white
			lrgb.x = 1.0;
			lrgb.y = 1.0;
			lrgb.z = 1.0;
		}
		else if (individual.status == -1)
		{ // if dead, draw in black
			lrgb.x = 0.0;
			lrgb.y = 0.0;
			lrgb.z = 0.0;
		}
		else if (individual.status == 1)
		{ // if in infected stage, draw as red
			lrgb.x = 1.0;
			lrgb.y = 0.0;
			lrgb.z = 0.0;
		}
		else if (individual.status == 2)
		{ // if in ill, draw as green
			lrgb.x = 0.0;
			lrgb.y = 1.0;
			lrgb.z = 0.0;
		}
		else if (individual.status == 3)
		{ // if in recovering, draw as blue
			lrgb.x = 0.0;
			lrgb.y = 0.0;
			lrgb.z = 1.0;
		}
		else if (individual.status == 4)
		{ // if in immune, draw as violet
			lrgb.x = 0.7;
			lrgb.y = 0.0;
			lrgb.z = 1.0;
		}
		else if (individual.status == 5)
		{ // if in vaccinated, draw as pink
			lrgb.x = 1.0;
			lrgb.y = 0.7;
			lrgb.z = 0.8;
		}
		rgb[tid] = lrgb;
	}
}