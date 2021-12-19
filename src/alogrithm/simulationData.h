#ifndef SIMULATION_DATA_H
#define SIMULATION_DATA_H

#include "individual.h"
#include "virus.h"
#include "gpuCode.h"

class SimulationData
{
private:
	ulong populationSize;
	dim3 threads;
	dim3 blocks;

	Individual *population;
	curandState *rand;
	Virus virus;

	//stores the rgb value for each pixel to display. used only to draw stuff
	float3 *rgb;

public:
	SimulationData(/* args */);
	~SimulationData();
};

SimulationData::SimulationData(/* args */)
{
}

SimulationData::~SimulationData()
{
}

#endif