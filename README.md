# COM392-final
Final project for the system programming COM392 class

Virus simulation project.

### Participants:
* Talkanbaev Artur
* Rasulov Emirlan
* Dillon Schwertz
* Tokbaev Arsen
* Kalysbek uulu Zhakshylyk

Roles were assigned on the need basis, and the task are drawn from the Github project.

### Setting up yaml dependencies

1. Clone repo

    ```
    git clone https://github.com/jbeder/yaml-cpp.git
    ```

2. Build from sources

    ```
    cd yaml-cpp
    mkdir build
    cd build
    cmake ..
    make
    ```

3. Copy the output to local dir

    ```
    mkdir -p ~/libs
    cp cp libyaml-cpp.a ~/libs/
    cp -r ../include/ ~/libs/
    ```

## Outline

The project consists of several main components, forming a hetorogenous computational system.

Wrapper component launches the applications, sets default values, prepares the configuration structures, and handles main computational calls. It as well handles the display of statistics.

The core component runs the CUDA kernel to compute the iterations of the simulation on the NVidia GPU card.

### Simulation algorithm

TBF

### Visualisation

TBF

### Analysis of the results

TBF
### Comparative analysis of configurations

TBF
### Conclusion

TBF
