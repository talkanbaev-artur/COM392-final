#include <stdio.h>
#include <cstdlib>
#include <math.h>
#include <thread>

#include "hostCode.h"
#include "gpuCode.h"
#include "randLib.h"
#include "animate.h"

/******************************************************************************/
// return information about CUDA CPU devices on this machine
int probeHost(){

  // PRINT CPU CORES INFO
  unsigned int numCores = std::thread::hardware_concurrency();
  printf("\nnum CPU cores on this machine: %d\n\n", numCores);

  // maybe add some stuff about type of CPU, etc..

  return(0);
}

/******************************************************************************/
int readHeader(AParams* PARAMS, FILE* infp){

  // read in the 54-byte header of .bmp file
	unsigned char header[54];
	fread(header, sizeof(unsigned char), 54, infp);
	PARAMS->width = *(int*)&header[18];
	PARAMS->height = *(int*)&header[22];
	PARAMS->size = 3 * PARAMS->width * PARAMS->height;	// three colors per pixel

	if (PARAMS->verbosity){
		printf("size of array = %lu x %lu = %lu\n",
					PARAMS->width, PARAMS->height, PARAMS->size);
		}

  return 0;
}

/*******************************************************************************
                       PROGRAM FUNCTIONS - multithreading CPU
*******************************************************************************/
int runEx2(AParams* PARAMS){

	// printf("filename: %s\n", PARAMS->fileName);
	// DO SOME ERROR CHECKING, PROOF THAT IT IS .BMP
	FILE *infp;
	if((infp = fopen(PARAMS->fileName, "r+b")) == NULL){
		printf("can't open filename: %s\n", PARAMS->fileName);
	  return 0;
	}

  // error checking would be good here
  readHeader(PARAMS, infp);

  // read data in to the heap from file, based on header information
	unsigned char* data=(unsigned char*)malloc(PARAMS->size * sizeof(unsigned char));
	fread(data, sizeof(unsigned char), PARAMS->size, infp);
	fclose(infp);

  // convert the big array into separate pixel maps of colors
	unsigned long mapSize = PARAMS->width*PARAMS->height*sizeof(float); // 800x800 SN.bmp

	float* graymap = (float*) malloc(mapSize); //P.gSize = P.gDIM * P.gDIM * sizeof(float);
	float* redmap = (float*) malloc(mapSize);	// 800x800 sn.bmp
	float* greenmap = (float*) malloc(mapSize);
	float* bluemap = (float*) malloc(mapSize);
  float* randmap = (float*) malloc(mapSize);

  // -- load the maps with data
	for(int i = 0; i < PARAMS->size; i += 3)
	{
	  // flip .BMP bgr to rgb (red - green - blue)
	  unsigned char temp = data[i];
	  data[i] = data[i+2];
	  data[i+2] = temp;

	  // read in data as floats to the four maps
	  int graymapIdx = (int) floor(i/3.0);
	  graymap[graymapIdx]   = (float) (data[i]+data[i+1]+data[i+2])/(255.0*3.0);
	  redmap[graymapIdx]    = (float) data[i]/255.0;
	  greenmap[graymapIdx]  = (float) data[i+1]/255.0;
	  bluemap[graymapIdx]   = (float) data[i+2]/255.0;
    randmap[graymapIdx]   = rand_frac();
	}

  // DO CPU MULTITHREADING PART OF EXERCISE 3 HERE

  GPU_Palette P1 = initGPUPalette(PARAMS->width, PARAMS->height);

  //  cudaMemcpy(&P1.gray, graymap, P1->gSize, cH2D);
	cudaMemcpy(P1.red, redmap, P1.memSize, cH2D);
	cudaMemcpy(P1.green, greenmap, P1.memSize, cH2D);
	cudaMemcpy(P1.blue, bluemap, P1.memSize, cH2D);


  CPUAnimBitmap animation(PARAMS->width, PARAMS->height, &P1);
  cudaMalloc((void**) &animation.dev_bitmap, animation.image_size());
  animation.initAnimation();

  while(1){
     int err = updatePalette(&P1);
     animation.drawPalette(PARAMS->width, PARAMS->height);
   	}


	free(graymap);
	free(redmap);
	free(greenmap);
	free(bluemap);

	return 0;
}

/*******************************************************************************
                       PROGRAM FUNCTIONS - multithreading CPU
*******************************************************************************/
int runVS(AParams* PARAMS){
  seed_randoms();

  PARAMS->sizePopulation = 1048576; // number of people in city (1024^2)

  GPU_Palette P1 = initPopulation();

  CPUAnimBitmap animation(PARAMS->width, PARAMS->height, &P1);
  cudaMalloc((void**) &animation.dev_bitmap, animation.image_size());
  animation.initAnimation();

  // initialize population with susceptibility and virus stage,
  // let's just do it on the CPU and copy to GPU:
  float* suscMap = (float*) malloc(PARAMS->sizePopulation * sizeof(float));
  int* stageMap = (int*) malloc(PARAMS->sizePopulation * sizeof(int));
  int* mingMap = (int*) malloc(PARAMS->sizePopulation * sizeof(int));
  for(long i = 0; i < PARAMS->sizePopulation; i++){
    suscMap[i] = rand_frac(); // everyone gets a susceptibility score
    stageMap[i] = 0; // set everyone to be at stage 0 (not infected)
    mingMap[i] = round(rand_frac() * 500); // a person mingles with
          // this number of other people on average per day
    }
  // infect some initial people
  int numInitialInfections = 5; // make this a user param
  for(int i = 0; i < numInitialInfections; i++){
    long randPerson = round(rand_frac()*1024*1024);
    stageMap[randPerson] = 1; // set person to infectious stage of virus
    }
	cudaMemcpy(P1.susc, suscMap, P1.memSize, cH2D);
	cudaMemcpy(P1.stage, stageMap, P1.memIntSize, cH2D);
	cudaMemcpy(P1.ming, mingMap, P1.memIntSize, cH2D);

  // simulation runs for 10 years, updating population once per day:
  for(int day = 0; day < 3650; day++){
     int err = updatePopulation(&P1, PARAMS, day);
     animation.drawPalette(PARAMS->width, PARAMS->height);
     // return number of newly infected and deaths per day
   	}

  // return number of people who died after ten years

}


/******************************************************************************/
