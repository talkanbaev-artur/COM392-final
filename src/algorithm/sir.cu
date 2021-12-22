#include "sir.h"

void SIR::run_sir(DailyRuntimeData *drd) {
    this->dS = -(this->beta * drd->s * drd->i);
    this->dI = this->beta * drd->s * drd->i;
    this->dR = this->r * drd->i;
}