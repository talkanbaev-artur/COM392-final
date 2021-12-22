#include "individual.h"
#include "virus.h"
#include "community.h"
#include "../random.cuh"

__device__ Individual::Individual(Params p, curandState *rand)
{
	this->status = 0;
	this->state = 0;
	this->immunity = 0;
	this->immunity_q = 0;
	this->vaccination_h = 0;
	const struct nd_value def_suc = {0.6, 0.12};
	const struct tnd_value def_age = {29, 13, 6, 80};
	curandState n_rand = *rand;
	this->susceptibility = normal(&n_rand, def_suc);
	this->age = tnormal(&n_rand, def_age);
	this->daily_contacts = {40, 150, 4, 2000};
	rand = &n_rand;
}

__device__ Individual::~Individual()
{
}

__device__ Virus::Virus(Params p)
{
	env_factor = p.virusEnvSupport;
	ntr = p.virusNtr;
	incubation_period = {14.0, 1.3, 2.0, 20.0};
	illness_period = {3.0, 1.0, 1.0, 5.0};
	recovery_period = {2.0, 0.6, 1.0, 3.0};
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
