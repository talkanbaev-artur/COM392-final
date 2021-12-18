# Documentation

This part of the project describes and syncs all features between team members.

## Main loop logic

To simulate the virus the main loop does following:

1. Initialise the app. Prepare defaults.
2. Read configurations and setup memory.
3. Upload defaults to GPU.
4. Start the initialisation phase.
5. Main loop for 10 years (each iteration is a day)
	1. Init temp memory. Setup daily factors.
	2. Phase I Virus activity
	3. Phase II Virus activity
	4. Update globals.
	5. Emit statistics (this later will be written in csv file and displayed)
6. Collect stats and save them.

## Virus algorithm

Currently virus acting in small communities is based on the two-stage system.

The first stage updates each person's stats (disease progress, immunity/vaccine decay, other stats) and collects the virus influence in the community. At this stage all current sources of the disease create their impact, which would take effect in the next stage. At this stage all virus-positive events and modifiers kick-in.

The second stage decomposes the virus influence from the previous stage, take into account all other stats and infects new people. At this stage all virus-negative events and modifiers kick-in.

In case of virus having the `environmental` trait, it would be reinforced by environment, creating the waves. Otherwise, the mutation of virus (which may happen in both stages) is possible only if virus is not beaten up. If the virus is beaten and does not has ability to recover, the virus algorithm skips all iteration till the end.

## Stats

### Individuals

###### Basic

1. Health status
	- Healthy (uninfected, not immune)
		- Continue to next stage
	- Infected (has three statuses)
		- Decrement infection state
		- Individuals with this status affect community's susceptible population
	- Immune/Vaccinated
		- Decrement immunity state
		- Virus mutation can cause faster decay of immunity
	- Dead
2. Infection status
	
	Duration of each period is calculated from virus stats.
	- Infected pre-illness (maximal contagiousness, no sympotoms, chance of skiping the next stage (symptomless))
	- Infected mid-illness (lowered contagiousness, symptoms, chance of dying)
	- Infected post-illness (minimal contagiousness, recovering symptoms, tiny chance of death)
3. Immunity status
	- Vaccination/Natural immunity

		Immunity decays over time (with the stage itself, as well as the immunity power).
		If immunity state is critically low, the immunity is considered to be obsolete (virus mutations affects speed of this process).
		- Quality. Affect on speed of immunity decay
		- State. Affect on the chance of being infected again
4. Characteristics (multipliers)
	- Susceptibility
	- Vaccine hesitancy

###### Advanced

TODO

### Virus

###### Basic

1. Contagiousness
	- Quality
	- Durations (pre-, mid-, and post-illness)
2. Case Fatality Rate (CFR)

###### Advanced

TODO

### Community

###### Basic

1. Status
	- Diseased population
		- Affect community characteristics
		- Affect virus contagiousness quality
	- Susceptible population
		- Affect community characteristics
		- Affect individual social group size
		- Affect individual household size
2. Characteristics (multipliers)
	- Government lockdown
		- Affect individual social group size
	- Mask mandate
		- Affect individual susceptibility

###### Advanced

TODO
