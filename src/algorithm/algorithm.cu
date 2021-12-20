#include "algorithm.h"
#include "individual.h"

__device__ void progressInfection(Individual individual);

__device__ void progressImmunity(Individual individual);

void runDay(SimulationData sd, int day) {}

__global__ void runAlgorithms(SimulationData sd) {}

__device__ void update_statuses(Individual *population) {
	int x = threadIdx.x + (blockIdx.x * blockDim.x);
	int y = threadIdx.y + (blockIdx.y * blockDim.y);
	int tid = x + (y * blockDim.x * gridDim.x);

	Individual individual = population[tid];
	
	switch (individual.status) {
		case -1: // dead
			break;
		case 0: // healthy
			break;
		case 1: // infected
			progressInfection(individual);
			break;
		case 2: // immune
			progressImmunity(individual);
			break;
		default: // super-human
			break;
	}

}

__device__ void progressInfection(Individual individual){
	individual.state -= 1;
	if (individual.state == 0) individual.status = 0;
}

__device__ void progressImmunity(Individual individual){
	individual.state -= 1;
	if (individual.state == 0) individual.status = 0;
}

__device__ void infect() {}
