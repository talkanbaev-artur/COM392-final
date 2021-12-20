#include "individual.h"
#include "virus.h"
#include "community.h"
#include "../random.cuh"

__device__ Individual::Individual(Params *p, curandState *rand)
{
	this->status = 0;
	this->state = 0;
	this->immunity = 0;
	this->immunity_q = 0;
	this->vaccination_h = 0;
	const struct nd_value def_suc = {0.5, 1};
	const struct tnd_value def_age = {40.0, 5, 10.0, 80.0};
	this->susceptibility = normal(rand, def_suc);
	this->age = tnormal(rand, def_age);
	this->daily_contacts = def_age;
}

__device__ Individual::~Individual()
{
}

__device__ Virus::Virus(Params p)
{
	env_factor = p.virusEnvSupport;
	ntr = p.virusNtr;
	incubation_period = {7.0, 1.3, 2.0, 14.0};
	illness_period = {3.0, 1.0, 1.0, 5.0};
	recovery_period = {2.0, 0.2, 1.0, 3.0};
	cfr = {0.5, 0.33};
}

__device__ Virus::~Virus()
{
}

__device__ Community::Community()
{
	igi = 0.0;
	sdf = 1.0;
}
__device__ Community::~Community() {}
