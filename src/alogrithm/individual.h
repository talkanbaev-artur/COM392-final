#ifndef INDIVIDUAL_API_H
#define INDIVIDUAL_API_H

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
	getStatus();
	Individual(/* args */);
	~Individual();
};

Individual::Individual(/* args */)
{
}

Individual::~Individual()
{
}

#endif