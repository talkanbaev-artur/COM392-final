#include <stdio.h>
#include <cstdlib>
#include <math.h>
#include <thread>

#include "hostCode.h"
#include "animate.h"

int runVS(AParams *PARAMS)
{

	GPU_Palette P1 = initPopulation();

	CPUAnimBitmap animation(PARAMS->width, PARAMS->height, &P1);
	cudaMalloc((void **)&animation.dev_bitmap, animation.image_size());
	animation.initAnimation();

	float *suscMap = (float *)malloc(PARAMS->sizePopulation * sizeof(float));
	int *stageMap = (int *)malloc(PARAMS->sizePopulation * sizeof(int));
	int *mingMap = (int *)malloc(PARAMS->sizePopulation * sizeof(int));
	for (long i = 0; i < PARAMS->sizePopulation; i++)
	{
	}
	// infect some initial people
	int numInitialInfections = 5; // make this a user param
	for (int i = 0; i < numInitialInfections; i++)
	{
	}
	cudaMemcpy(P1.susc, suscMap, P1.memSize, cH2D);
	cudaMemcpy(P1.stage, stageMap, P1.memIntSize, cH2D);
	cudaMemcpy(P1.ming, mingMap, P1.memIntSize, cH2D);

	// simulation runs for 10 years, updating population once per day:
	for (int day = 0; day < 3650; day++)
	{
		int err = updatePopulation(&P1, PARAMS, day);
		animation.drawPalette(PARAMS->width, PARAMS->height);
		// return number of newly infected and deaths per day
	}

	freeGPUPalette(&P1);
}