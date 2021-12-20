#include "algorithm.h"
#include "individual.h"
#include "virus.h"
#include "community.h"
#include "../random.cuh"

void runDay(SimulationData sd, int day)
{
	DailyRuntimeData *dd_g;
	DailyRuntimeData dd = DailyRuntimeData();

	cudaMalloc((void **)&dd_g, sizeof(DailyRuntimeData));

	runAlgorithms<<<sd.blocks, sd.threads>>>(sd, dd_g);

	cudaMemcpy(&dd, dd_g, sizeof(DailyRuntimeData), cD2H);
}

__global__ void runAlgorithms(SimulationData sd, DailyRuntimeData *drd)
{
	update_statuses(sd.population, sd.virus, sd.communities, sd.rand);
}

__device__ void update_statuses(Individual *population, Virus *virus, Community *communities, curandState *rand)
{
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	Individual individual = population[tid];
	Community i_community = communities[blockIdx.y * blockDim.y + blockIdx.x];
	curandState lcu = rand[tid];

	float individual_v;
	// individual.susceptibility + (individual.age/100) + (community.sdf * individual.daily_contacts) + virus.nrt

	switch (individual.status)
	{
	case -1: // dead
		individual_v = 0;
		break;
	case 0: // healthy
		individual_v = individual.susceptibility + (individual.age/100) + (i_community.sdf * tnormal(&lcu, individual.daily_contacts)) + virus->ntr;
		break;
	case 1: // infected
		individual_v = individual.susceptibility + (individual.age/20) + (i_community.sdf * tnormal(&lcu, individual.daily_contacts)) + virus->ntr;
		individual.state -= 1;
		if (individual.state == 0)
		{
			individual.status++;
			individual.state = tnormal(&lcu, virus->illness_period);
		}
		break;
	case 2: // ill
		individual_v = individual.susceptibility + (individual.age/10) + (i_community.sdf * tnormal(&lcu, individual.daily_contacts)) + virus->ntr;
		individual.state -= 1;
		if (individual.state == 0)
		{
			individual.status++;
			individual.state = tnormal(&lcu, virus->recovery_period);
		}
		break;
	case 3: // recovering
		individual_v = individual.susceptibility + (individual.age/50) + (i_community.sdf * tnormal(&lcu, individual.daily_contacts)) + virus->ntr;
		individual.state -= 1;
		if (individual.state == 0)
		{
			individual.status++;
			individual.state = 100;
		}
		break;
	case 4: // immune
	case 5:
		individual_v = (individual.susceptibility/10) + (individual.age/100) + (i_community.sdf * tnormal(&lcu, individual.daily_contacts)) + virus->ntr;
		individual.state -= 1;
		if (individual.state == 0)
			individual.status = 0;
		break;
	default: // super-human
		break;
	}

	rand[tid] = lcu;
	population[tid] = individual;
	communities[blockIdx.y * blockDim.y + blockIdx.x] = i_community;
}

__device__ void infect() {}

__device__ void drawStage(Individual *population, float3 *rgb, ulong sizePopulation) {
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	Individual individual = population[tid];
	float3 lrgb = rgb;
	if (tid < sizePopulation){
		if (individual.status == 0) {  // if not infected, draw as white
			lrgb[tid].x = 1.0;
			lrgb[tid].y = 1.0;
			lrgb[tid].z = 1.0;
		}
		else if (individual.status == -1) {  // if dead, draw in black
			lrgb[tid].x = 0.0;
			lrgb[tid].y = 0.0;
			lrgb[tid].z = 0.0;
		}
		else if (individual.status < 1) { // if in infected stage, draw as red
			lrgb[tid].x = 1.0;
			lrgb[tid].y = 0.0;
			lrgb[tid].z = 0.0;
		}
		else if (individual.status < 2) { // if in ill, draw as green
			lrgb[tid].x = 0.0;
			lrgb[tid].y = 1.0;
			lrgb[tid].z = 0.0;
		}
		else if (individual.status < 3) { // if in recovering, draw as blue
			lrgb[tid].x = 0.0;
			lrgb[tid].y = 0.0;
			lrgb[tid].z = 1.0;
		}
		else if (individual.status < 4) { // if in immune, draw as violet
			lrgb[tid].x = 0.7;
			lrgb[tid].y = 0.0;
			lrgb[tid].z = 1.0;
		}
		else if (individual.status < 5) { // if in vaccinated, draw as pink
			lrgb[tid].x = 1.0;
			lrgb[tid].y = 0.7;
			lrgb[tid].z = 0.8;
		}
	}
}