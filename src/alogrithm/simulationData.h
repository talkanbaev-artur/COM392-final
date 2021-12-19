#ifndef SIMULATION_DATA_H
#define SIMULATION_DATA_H

#include "individual.h"
#include "virus.h"
#include "gpuCode.h"

class DailyRuntimeData
{
private:
	//global V value for the simulation
	double gV;

public:
	DailyRuntimeData(/* args */);
	~DailyRuntimeData();
};

class SimulationData
{
private:
	ulong populationSize;
	dim3 threads;
	dim3 blocks;

	//Following data is allocated on GPU

	Individual *population;
	curandState *rand;
	Virus virus;

	//stores the rgb value for each pixel to display. used only to draw stuff
	float3 *rgb;

public:
	SimulationData(/* args */);
	~SimulationData();
};

#endif