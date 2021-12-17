/*******************************************************************************
*
*   COMMENTS GO HERE
*
*   TODO LIST GOES HERE
*
*******************************************************************************/
#include <cuda.h>
#include <stdio.h>
#include "gpuCode.h"
#include "params.h"

texture<float, 2> texBlue;

/******************************************************************************/
// VIRUS SIMULATION CODE
/******************************************************************************/
GPU_Palette initPopulation(void) // for simulating virus
{
  GPU_Palette X;

  X.gThreads.x = 32;  // 32 x 32 = 1024 threads per block
  X.gThreads.y = 32;
  X.gThreads.z = 1;
  X.gBlocks.x = 32;  // 32 x 32 = 1024 blocks
  X.gBlocks.y = 32;
  X.gBlocks.z = 1;

  X.palette_width = 1024;       // save this info
  X.palette_height = 1024;
  X.num_pixels = 1024*1024; // 1048576
  X.memSize =  1024*1024 * sizeof(float);
  X.memIntSize =  1024*1024 * sizeof(int);

  // keep color stuff for visualizing virus spread
  cudaError_t err;
  err = cudaMalloc((void**) &X.red, X.memSize);
  if(err != cudaSuccess){
    printf("cuda error allocating red = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }
  err = cudaMalloc((void**) &X.green, X.memSize);
  if(err != cudaSuccess){
    printf("cuda error allocating green = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }
  err = cudaMalloc((void**) &X.blue, X.memSize);  // b
  if(err != cudaSuccess){
    printf("cuda error allocating blue = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }
  err = cudaMalloc((void**) &X.rand, X.num_pixels * sizeof(curandState));
  if(err != cudaSuccess){
    printf("cuda error allocating blue = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }

  // for initializing population with (random) susceptibility ratings
  err = cudaMalloc((void**) &X.susc, X.memSize);
  if(err != cudaSuccess){
    printf("cuda error allocating susc = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }
  err = cudaMalloc((void**) &X.stage, X.memIntSize);
  if(err != cudaSuccess){
    printf("cuda error allocating stage = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }
  err = cudaMalloc((void**) &X.ming, X.memIntSize);
  if(err != cudaSuccess){
    printf("cuda error allocating ming = %s\n", cudaGetErrorString(err));
    exit(EXIT_FAILURE);
    }


  initRands <<< X.gBlocks, X.gThreads >>> (X.rand, time(NULL), X.num_pixels);

  cudaChannelFormatDesc desc= cudaCreateChannelDesc <float>();
  unsigned int pitch = sizeof(float)*1024;
  cudaBindTexture2D(NULL, texBlue, X.blue, desc, 1024, 1024, pitch);

  // set reds, greens, and blues to zero
  setMap <<< X.gBlocks, X.gThreads >>> (X.red, 0.0, X.num_pixels);
  setMap <<< X.gBlocks, X.gThreads >>> (X.green, 0.0, X.num_pixels);
  setMap <<< X.gBlocks, X.gThreads >>> (X.blue, 0.0, X.num_pixels);

  return X;
}

/******************************************************************************/
// analogous to updatePalette in runmode 1
int updatePopulation(GPU_Palette* P, AParams* PARAMS, int day){

  // 1) have people mingle, some will come in contact with contageous people
  //    where infection status will go from 'not infected' to
  //    'contageous' based on dice roll and spread rate
  // 2) after period of time, have people go from contageous to recovery
  // 3) after another period, go from recovery to either immune or to death
  //    based on susceptibility and deadliness of virus
  // 4) if want to visualize, write a kernel that updates colors based on stage
  // 5) return how many people die in the simulation, better yet, track
  //    infection waves over time

  // place-holder code, just draw the population every day over ten years;
  // whole screen goes from black to white over time.
  float goo = day/3650.0;
  setMap <<< P->gBlocks, P->gThreads >>> (P->red, goo, P->num_pixels);
  setMap <<< P->gBlocks, P->gThreads >>> (P->green, goo, P->num_pixels);
  setMap <<< P->gBlocks, P->gThreads >>> (P->blue, goo, P->num_pixels);

  return 0;
}

/******************************************************************************/
__global__ void setMap(float* map, float val, long sizePopulation){

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  int tid = x + (y * blockDim.x * gridDim.x);

  if (tid < sizePopulation){
    map[tid] = val;
  }
}

/******************************************************************************/
//__global__ void updateReds(float* red){
__global__ void updateReds(float* red, curandState* gRand){

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  int tid = x + (y * blockDim.x * gridDim.x);

  // generate noise
  curandState localState = gRand[tid];
  float theRand = curand_uniform(&localState); // value between 0-1
//  float theRand = curand_poisson(&localState, .5);
  gRand[tid] = localState;

  // sparkle the reds:
  if(theRand > .999) red[tid] = red[tid] *.9;
  else if(theRand < .001) red[tid] = (1.0-red[tid]);
}

/******************************************************************************/
__global__ void updateGreens(float* green){

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  int tid = x + (y * blockDim.x * gridDim.x);

  green[tid] = green[tid] *.888;
//  green[tid] = green[tid] * 0;
}

/******************************************************************************/
__global__ void initRands(curandState* state, unsigned long seed, unsigned long numPixels){

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  int tid = x + (y * blockDim.x * gridDim.x);

  if(tid < numPixels) curand_init(seed, tid, 0, &state[tid]);

}

/******************************************************************************/
__global__ void updateBlues(float* blue){

  int x = threadIdx.x + (blockIdx.x * blockDim.x);
  int y = threadIdx.y + (blockIdx.y * blockDim.y);
  int tid = x + (y * blockDim.x * gridDim.x);

  // find neighborhood average blue value
  float acc = 0.0;
  for (int i = -20; i <= 20; i++){      // 11 pixels-threads in x direction
    for (int j = -20; j <= 20; j++){    // 11 pixels-threads in the y direction
      acc += tex2D(texBlue, x+i, y+j);
    }
  }
  acc /= 241.0;

  blue[tid] = acc;

}