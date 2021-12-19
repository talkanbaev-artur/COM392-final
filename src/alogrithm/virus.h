#ifndef VIRUS_API_H
#define VIRUS_API_H

#include "random.h"

//Virus holds the virus data. Usually this instance would be a singleton, which is updated in cpu each day.
class Virus
{
private:
	//Case fatality rate describes the general boundaries for deadliness of the virus
	//note: cfr's actuall value is calculated no more than blocks-times a day. This behaviour may change
	nd_value cfr;

	//Effective transmission rate describes the general rate of virus spread
	//This value represents the general characteristics of virus' ability to transmit to new hosts
	double etr;

	//following 3 generation structs are used to generate the
	//corresponding value for each infected person
	//When someone gets to the indicated stage the tnormal function returns the actual value for the stage
	//These structs are used to describe the boundaries and probabilities of durations of various stages

	//Incubation period generation struct
	tnd_value incubation_period;
	//illness period generation struct
	tnd_value illness_period;
	//recovery period generation struct
	tnd_value recovery_period;

	//this value is used to determine chances of virus mutating
	//more significant generated outputs determine the immunity decay
	nd_value genetic_volatility;

	//Environmental factor describes the external support for virus.
	//If value is not 0, then each day it has affect on ability to infect new people from natural causes (zoonosis)
	double env_factor;

public:
	Virus(/* args */);
	~Virus();
};

Virus::Virus(/* args */)
{
}

Virus::~Virus()
{
}

#endif