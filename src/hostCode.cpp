#include <stdio.h>
#include <cstdlib>
#include <math.h>
#include <thread>

#include "hostCode.h"
#include "animate.h"
#include "algorithm/algorithm.h"
#include "algorithm/simulationData.h"

int runVS(Params *params)
{

	GPU_Palette P1 = initPopulation();
	SimulationData sd(*params);

	CPUAnimBitmap animation(params->getWidth(), params->getHeight(), &P1);
	cudaMalloc((void **)&animation.dev_bitmap, animation.image_size());
	animation.initAnimation();

	// simulation runs for 10 years, updating population once per day:
	//for (int day = 0; day < 3650; day++)
	//{
	//	int err = updatePopulation(&P1, day);
	//	animation.drawPalette(params->getWidth(), params->getHeight());
	//	// return number of newly infected and deaths per day
	//}

	freeGPUPalette(&P1);
}