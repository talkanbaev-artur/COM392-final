#ifndef INDIVIDUAL_API_H
#define INDIVIDUAL_API_H

#include "../params.h"
#include "../random.cuh"

//Individual is class which stores all stats and state data about
//a single individual.
class Individual
{
private:
	// *** MAJOR STATS ***

	//Health status is used to determine the status of human
	//-1 dead, 0 healthy, 1 infected, 2 ill, 3 recorvering, 4 immune, 5 vaccinated
	int status;
	//State is used to determine the exact detail of the current stage
	//If not dead or health, this number is decremented each day and when reaching 0, changes status
	int state;

	// *** CHARACTERISTICS ***

	//Susceptibility shows individual health characteristics as one value.
	//Initialised using the flat normal distribution with low mean value.
	//THIS IS A VERY GENERAL PARAMETR
	double susceptibility;

	//Age is self explanatory. Yet to be decided how to generate it logicaly.
	int age;

	//Vaccination heistancy is used to regulate the rate of vaccination
	double vaccination_h;

	//Is used to determine the avarage number of contacts per day
	tnd_value daily_contacts;

	// *** IMMUNITY ***

	//Immunity is a float value between 0.0 and 1.0, which shows the quality of ones immunity.
	//It is used to people with statuses 4 and 5, when trying to re-infect them.
	//
	//With virus mutating, this value will decay to 0. If it decays lower than 0, the status changes to healthy.
	double immunity;
	//Quality of immunity is used to variate the speed of immunity decay
	double immunity_q;

	//later it would nice to have an n-char descriptor for the virus variation
	//and assign the immunity based on this dna(rna) sample

public:
	//Public method to get status. Mainly used to display the population map.
	__device__ int getStatus() { return status; }
	__device__ int getState() { return state; }
	__device__ int getImmunity() { return immunity; }
	__device__ double getSuc() { return susceptibility; }
	__device__ int getAge() { return age; }
	__device__ tnd_value getDailyContacts() { return daily_contacts; }

	//GPU constructor. Requires the pointer to a rand generator - not to a multiple generators!
	__device__ Individual(Params *p, curandState *rand);
	__device__ ~Individual();
};

#endif