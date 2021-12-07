#ifndef hInterfaceLib
#define hInterfaceLib

#include "params.h"
#include "gpuCode.h"

int setDefaults(AParams *PARAMS);
int usage();
int viewParams(const AParams *PARAMS);
char crack(int argc, char** argv, char* flags, int ignore_unknowns);

#endif
