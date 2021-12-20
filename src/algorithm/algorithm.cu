#include "algorithm.h"
#include "individual.h"
<<<<<<< HEAD
#include "virus.h"
#include "../random.cuh"
=======

__device__ void progressInfection(Individual individual);

__device__ void progressImmunity(Individual individual);
>>>>>>> 1b1d8df36116cacb26bc415f09d92a2bc4355ce8

void runDay(SimulationData sd, int day) {}

__global__ void runAlgorithms(SimulationData sd) {}

<<<<<<< HEAD
__device__ void update_statuses(Individual *population, Virus *virus, curandState *rand) {
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
			individual.state -= 1;
			if (individual.state == 0) individual.status++;
			individual.state = tnormal(rand, virus->illness_period);
			break;
		case 2: // ill
			individual.state -= 1;
			if (individual.state == 0) individual.status++;
			individual.state = tnormal(rand, virus->recovery_period);
			break;
		case 3: // recovering
			individual.state -= 1;
			if (individual.state == 0) individual.status++;
			individual.state = 100;
			break;
		case 4: // immune
			individual.state -= 1;
			if (individual.state == 0) individual.status = 0;
			break;
		default: // super-human
			break;
	}

}
=======
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

>>>>>>> 1b1d8df36116cacb26bc415f09d92a2bc4355ce8
__device__ void infect() {}
