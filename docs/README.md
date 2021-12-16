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
    - Infected
        - Increment infection status
        - Affect community diseased population
        - Affect community susceptible population
    - Immune
        - Increment immunity status
        - Affect individual susceptibliity
    - Dead
        - Affect individual social group size
2. Infection status
    - Uninfected
    - Infected pre-illness (contagious, no sympotoms)
        - Duration
    - Infected mid-illness (contagious, symptoms)
        - Duration
    - Infected post-illness (non-contagious, recovering symptoms)
        - Duration
3. Immunity status
    - Vaccination
        - Quality (affect on susceptibliity)
        - Duration
    - Natural immunity (begins post-illness)
        - Quality (affect on susceptibliity)
        - Duration
4. Characteristics (multipliers)
    - Susceptibility
    - Vaccine hesitancy
    - Social group size (average number of random contacts)
    - Household size (number of daily contacts)

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
