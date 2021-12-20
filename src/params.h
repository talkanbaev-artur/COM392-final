#ifndef SIMULATION_PARAMS
#define SIMULATION_PARAMS

class Params
{
private:
	int height, width;
	long populationSize;

public:
	double virusEnvSupport;
	double virusNtr;
	~Params(){};
	Params(int height, int width) : height(height), width(width),
									populationSize(height * width){};
	int getWidth() { return width; }
	int getHeight() { return height; }
	long getPopSize() { return populationSize; }
};

#endif