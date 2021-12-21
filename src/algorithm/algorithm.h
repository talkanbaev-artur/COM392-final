#ifndef ALGORITHM_H
#define ALGORITHM_H

#include "simulationData.h"

//Main cpu caller function. It calls the pre- and post- alog code, manages stats and launches algo
void runDay(SimulationData *sd, int day);

//First stage of daily progress. Updates individuals statuses, calculates V
__device__ void update_statuses(Individual *population, Virus *virus, Community *c, curandState *rand);

//Second stage of daily progress. Infects people from V
__device__ void infect(Individual *pop, curandState *rand);

//main algorithm function. It prepares individuals for each day, and runs both stages
__global__ void runAlgorithms(SimulationData *sd, DailyRuntimeData *drd);

__device__ void drawStage(Individual *population, float3 *rgb, ulong sizePopulation);
#endif