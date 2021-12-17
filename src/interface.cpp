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
      default : return(0);
    	}
  	}

	printf("\n -- running virus simulator --\n");
	runVS(&PARAMS);
	return 0;
}

int setDefaults(AParams *PARAMS){
/*
    PARAMS->verbosity       = 0;
    PARAMS->runMode         = 2;

		// for runmode = 1 (play with pixels);
		// this overwritten upon opening image file in runmode 1, but runmode 2
		// assumes a population of 1024 x 1024 = 1048576
    PARAMS->height     = 1024;
    PARAMS->width      = 1024;
    PARAMS->size      = 1024*1024*3; // 800x800 pixels x 3 colorsS

		// for runmode = 2 (virus spread simulator)
		PARAMS->sizePopulation = 1024*1024; // = 1,048,576
	  PARAMS->deadliness = 0.5; // 0 to 1;
	  PARAMS->duration = 7; // number of days a person is infectious before symptoms
	  PARAMS->spreadrate = 0.5;	// 0 to 1
		// ADD MORE PARAMETERS HERE AND IN PARAMS.H AS NEEDED, ADD TO INTERFACE
*/
    return 0;
}