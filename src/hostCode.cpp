#include <unistd.h>
#include <stdio.h>
#include "hostCode.h"
#include "animate.h"
#include "algorithm/algorithm.h"
#include "algorithm/simulationData.h"

int runVS(Params *params)
{

	SimulationData sd(*params);

	CPUAnimBitmap animation(params->getWidth(), params->getHeight(), &sd);
	cudaMalloc((void **)&animation.dev_bitmap, animation.image_size());
	animation.initAnimation();

	// simulation runs for 10 years, updating population once per day:
	for (int day = 0; day < 3650; day++)
	{
		runDay(&sd, day);
		animation.drawPalette(params->getWidth(), params->getHeight());
		// sleep(0);
		printf("Day #%d\n", day);
		// return number of newly infected and deaths per day
	}
}