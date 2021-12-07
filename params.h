#ifndef hParamsLib
#define hParamsLib

class AParams {
public:

  int   verbosity;
  int   runMode;
  char  fileName[80];

  long sizePopulation; // let's just hardwire as 1024^2 for now
  float deadliness; // value 0 to 1 = probability that someone dies (based on formula)
  int duration; // days the virus is spreading before symptoms - infectious stage
  float spreadrate; // value 0 - 1 = how easly virus spreads

  int   height;
  int   width;
  int   size;

};


#endif
