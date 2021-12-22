#ifndef SIR_H
#define SIR_H

#include "simulationData.h"

class SIR
{
public:
    // parameter for probability of new infection
    float beta;

    // parameter for probability of recovery
    float r;

    // calculated with s,i,r values in simulationData
    // susceptible population change
    float dS;

    // infected population change
    float dI;

    // recovered population change
    float dR;

    void run_sir(DailyRuntimeData *drd);
};

#endif