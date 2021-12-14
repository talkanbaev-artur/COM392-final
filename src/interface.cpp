/*******************************************************************************
*
*
*
*******************************************************************************/
#include <stdio.h>
#include <cstdlib>
#include <string.h>
#include <time.h>

#include "interface.h"
#include "gpuCode.h"
#include "hostCode.h"
#include "params.h"
#include "animate.h"
#include "crack.h"

/******************************************************************************/
int main(int argc, char *argv[]){

	unsigned char ch;
	AParams PARAMS;

	struct timespec start, finish;
	double elapsed;

  setDefaults(&PARAMS);

  // -- update default parameters entered from command line:
//  if(argc<2){usage(); return 1;} // must be at least one arg (fileName)
	while((ch = crack(argc, argv, "r|v|f|", 0)) != NULL) {
	  switch(ch){
    	case 'r' : PARAMS.runMode = atoi(arg_option); break;
      case 'v' : PARAMS.verbosity = atoi(arg_option); break;
			case 'f' : strcpy(PARAMS.fileName, arg_option); break;
      default  : usage(); return(0);
    	}
  	}

  if (PARAMS.verbosity == 2) viewParams(&PARAMS);


  // -- run the system depending on runMode
  switch(PARAMS.runMode){
      case 0: // get hardware information (& reset GPU)
				if (PARAMS.verbosity == 1) printf("\n -- probing hardware -- \n");
				probeHost();
				probeGPU();
				break;
			case 1: // launch picture to test drawing function
				if (PARAMS.verbosity == 1) printf("\n -- play with pixels --  \n");
				runEx2(&PARAMS);	// draw picture
				break;
			case 2: // virus simulation code
				if (PARAMS.verbosity == 1) printf("\n -- running virus simulator --\n");
				runVS(&PARAMS);
				break;
			case 3: // Example code to test timing
				if (PARAMS.verbosity) printf("\n -- testing clock -- \n");
					clock_gettime(CLOCK_MONOTONIC, &start);
					for(unsigned long i =0; i < 1000000000; i++){ // burn 1G cycles
						}
					clock_gettime(CLOCK_MONOTONIC, &finish);
					elapsed = (finish.tv_sec - start.tv_sec);	// get the seconds
					elapsed += (finish.tv_nsec - start.tv_nsec) / 1000000000.0; // sec fraction
					printf("time used: %.2f\n", elapsed);
				break;
      case 4:
				// etc..
				break;
      default: printf("no valid run mode selected\n");
				break;
  }

return 0;
}


/******************************************************************************/
int setDefaults(AParams *PARAMS){

    PARAMS->verbosity       = 0;
    PARAMS->runMode         = 2;

		// for runmode = 1 (play with pixels);
		// this overwritten upon opening image file in runmode 1, but runmode 2
		// assumes a population of 1024 x 1024 = 1048576
    PARAMS->height     = 1024;
    PARAMS->width      = 1024;
    PARAMS->size      = 1024*1024*3; // 800x800 pixels x 3 colors

		// for runmode = 2 (virus spread simulator)
		PARAMS->sizePopulation = 1024*1024; // = 1,048,576
	  PARAMS->deadliness = 0.5; // 0 to 1;
	  PARAMS->duration = 7; // number of days a person is infectious before symptoms
	  PARAMS->spreadrate = 0.5;	// 0 to 1
		// ADD MORE PARAMETERS HERE AND IN PARAMS.H AS NEEDED, ADD TO INTERFACE

    return 0;
}

/******************************************************************************/
int usage()
{
	// CLEAN THIS UP

	printf("USAGE:\n");
	printf("-r[val] -v[val] filename\n\n");
  printf("e.g.> ex2 -r1 -v1 imagename.bmp\n");
  printf("v  verbose mode (0:none, 1:normal, 2:params\n");
  printf("r  run mode (1:CPU, 2:GPU)\n");

  return(0);
}

/******************************************************************************/
int viewParams(const AParams *PARAMS){

	// CLEAN THIS UP

  printf("--- PARAMETERS: ---\n");
  printf("run mode: %d\n", PARAMS->runMode);
  printf("image height: %d\n", PARAMS->height);
  printf("image width: %d\n", PARAMS->width);
  printf("data size: %d\n", PARAMS->size);

  return 0;
}
/******************************************************************************/
